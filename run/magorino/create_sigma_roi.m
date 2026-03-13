% CREATE_SIGMA_ROI
% Draw background noise ROI for MAGORINO sigma estimation.
% Press ENTER to confirm ROI once drawn.

%% ------------------------------------------------------------------------
% Setup paths relative to script location
%% ------------------------------------------------------------------------

scriptDir = fileparts(mfilename('fullpath'));

addpath(fullfile(scriptDir,'..','..','config'))
addpath(genpath(fullfile(scriptDir,'..','..','src')))

cfg = load_config();


%% ------------------------------------------------------------------------
% Select MAGORINO input file
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

if ~isfield(S,'imData')
    error('Selected file does not contain imData struct.');
end

imData = S.imData;


%% ------------------------------------------------------------------------
% Extract metadata
%% ------------------------------------------------------------------------

if ~isfield(imData,'patientID') || ~isfield(imData,'timepoint')
    error('imData.patientID or imData.timepoint missing.');
end

patientID = imData.patientID;
timepoint = imData.timepoint;


%% ------------------------------------------------------------------------
% Determine analysis folder
%% ------------------------------------------------------------------------

analysisTimepointPath = fullfile(cfg.paths.analysisData, patientID, timepoint);

magorinoPath = fullfile(analysisTimepointPath, 'magorino');

if ~exist(magorinoPath,'dir')
    mkdir(magorinoPath);
end


%% ------------------------------------------------------------------------
% Slice selection
%% ------------------------------------------------------------------------

disp('Browse slices in viewer to choose background air region.')

sliceViewer(imData.images(:,:,:,1,1))

nSlices = size(imData.images,3);
fprintf('Volume contains %d slices\n', nSlices)

sliceIdx = input('Enter slice index for sigma ROI: ');
echoIdx = 1;


%% ------------------------------------------------------------------------
% Extract selected image
%% ------------------------------------------------------------------------

img2d = squeeze(imData.images(:,:,sliceIdx,1,echoIdx));
img2d = double(img2d);


%% ------------------------------------------------------------------------
% Draw ROI with keyboard confirmation
%% ------------------------------------------------------------------------

f = figure;

imshow(img2d,[])
colormap gray
axis image
hold on

title({
    sprintf('%s %s | Slice %d | Echo %d', patientID,timepoint,sliceIdx,echoIdx)
    'Draw ROI in background air'
    'Press ENTER to confirm'
    })

h = drawfreehand('Color','r','FaceAlpha',0.1);

set(f,'KeyPressFcn',@(src,event) confirmROI(event))

uiwait(f)

BWmask = createMask(h);

visboundaries(BWmask,'Color','r','LineWidth',1.5);

pause(0.5)

close(f)


%% ------------------------------------------------------------------------
% Save ROI
%% ------------------------------------------------------------------------

roi = struct();
roi.mask = BWmask;
roi.slice = sliceIdx;
roi.size = size(img2d);

save(fullfile(magorinoPath,'sigma_roi.mat'),'roi')

fprintf('\nSigma ROI saved to:\n%s\n\n', fullfile(magorinoPath,'sigma_roi.mat'));


%% ------------------------------------------------------------------------
% ROI confirmation function
%% ------------------------------------------------------------------------

function confirmROI(event)

    if strcmp(event.Key,'return')
        uiresume
    end

end
