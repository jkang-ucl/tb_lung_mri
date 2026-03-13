% GENERATE_SIGMA_CORRECTION
% Generate and save MAGORINO sigma correction factor.

scriptDir = fileparts(mfilename('fullpath'));

addpath(fullfile(scriptDir,'..','..','config'))
addpath(genpath(fullfile(scriptDir,'..','..','src')))

cfg = load_config();

reps = 10;
fieldStrength = 3;

fprintf('Generating sigma correction...\n');
fprintf('Field strength: %.1f T\n', fieldStrength);
fprintf('Repetitions: %d\n', reps);

sigmaCorrection = sigmaEstimationSim(reps, fieldStrength);

savePath = fullfile(scriptDir, '..', '..', 'src', 'magorino', 'Fitting', 'sigmaCorrection.mat');
save(savePath, 'sigmaCorrection');

fprintf('Saved sigmaCorrection to:\n%s\n', savePath);
disp('sigmaCorrection =')
disp(sigmaCorrection)
