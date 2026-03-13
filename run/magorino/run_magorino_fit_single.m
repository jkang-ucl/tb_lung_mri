% RUN_MAGORINO_FIT_SINGLE
% Test MAGORINO fitting on a single slice.

%% ------------------------------------------------------------------------
% Setup paths
%% ------------------------------------------------------------------------

scriptDir = fileparts(mfilename('fullpath'));

addpath(fullfile(scriptDir,'..','..','config'))
addpath(genpath(fullfile(scriptDir,'..','..','src')))

cfg = load_config();


%% ------------------------------------------------------------------------
% Select MAGORINO input
%% ------------------------------------------------------------------------

[filename, pathname] = uigetfile( ...
    '*.mat', ...
    'Select MAGORINO imData file', ...
    cfg.paths.processedData);

if isequal(filename,0)
    error('No file selected.');
end

matFile = fullfile(pathname, filename);

S = load(matFile);
imData = S.imData;


%% ------------------------------------------------------------------------
% Locate sigma ROI
%% ------------------------------------------------------------------------

patientID = imData.patientID;
timepoint = imData.timepoint;

analysisPath = fullfile(cfg.paths.analysisData, patientID, timepoint);
magorinoPath = fullfile(analysisPath,'magorino');

roiFile = fullfile(magorinoPath,'sigma_roi.mat');

if ~exist(roiFile,'file')
    error('sigma_roi.mat not found. Run create_sigma_roi first.');
end

load(roiFile)   % loads variable "roi"


%% ------------------------------------------------------------------------
% Extract slice for testing
%% ------------------------------------------------------------------------

sliceIdx = roi.slice;

fprintf('Running MAGORINO on slice %d\n', sliceIdx)

imDataSlice = imData;
imDataSlice.images = double(imData.images(:,:,sliceIdx,:,:));

roiSlice = roi;
roiSlice.slice = 1;

%% ------------------------------------------------------------------------
% Run MAGORINO fitting
%% ------------------------------------------------------------------------


fprintf('Starting MAGORINO fitting...\n')

tic
maps = MultistepFitImage(imDataSlice, roiSlice);
toc
fprintf('Fitting complete.\n')


%% ------------------------------------------------------------------------
% Display result
%% ------------------------------------------------------------------------

figure
imshow(maps.filtMaps.PDFF.gauss5,[0 1])
colormap parula
colorbar

title(sprintf('%s %s | Slice %d | PDFF', ...
    patientID, timepoint, sliceIdx))


%% ------------------------------------------------------------------------
% Save output
%% ------------------------------------------------------------------------

save(fullfile(magorinoPath,'maps_single_slice.mat'),'maps')

fprintf('\nMAGORINO maps saved to:\n%s\n\n', ...
    fullfile(magorinoPath,'maps_single_slice.mat'));
