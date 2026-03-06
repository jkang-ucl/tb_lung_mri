% IMPORT_DICOMS  Import raw DICOM scans into MATLAB format.
%
% DESCRIPTION
%   This script is the entry point for the DICOM import pipeline.
%   It scans the RawDICOM directory for available scan sessions,
%   checks which scans have already been processed, and imports
%   any new scans that have not yet been converted.
%
% PIPELINE LOGIC
%   1. Load config
%   2. Find raw scans
%   3. Check which scans are already processed
%   4. Group DICOMs into:
%        - T2_Dixon_TE30
%        - T2_Dixon_TE50
%        - qDixon_raw (split by EchoTime, excluding TE = 0)
%   5. Split T2 Dixon groups by ImageType:
%        - water
%        - fat
%        - IP
%        - OP
%   6. Save imported .mat files into the Processed folder
%
% RAW DATA STRUCTURE
%   RawDICOM/
%       PatientID/
%           TP1/
%           TP2/
%
% PROCESSED DATA STRUCTURE
%   Processed/
%       PatientID/
%           TP1/
%               imports/
%                   T2_Dixon_TE30/
%                       water/
%                           acquisition.mat
%                       fat/
%                           acquisition.mat
%                       IP/
%                           acquisition.mat
%                       OP/
%                           acquisition.mat
%                   T2_Dixon_TE50/
%                       water/
%                           acquisition.mat
%                       fat/
%                           acquisition.mat
%                       IP/
%                           acquisition.mat
%                       OP/
%                           acquisition.mat
%                   qDixon_raw/
%                       TE_1p037/
%                           acquisition.mat
%                       ...
%
% NOTES
%   - Raw data is never modified.
%   - Importing is only performed once per scan session.
%   - The script automatically skips scans that have already
%     been processed.

addpath('../config')
addpath(genpath('../src'))

cfg = load_config();

rawScans = find_raw_scans(cfg.paths.rawData);
processedScans = find_processed_scans(cfg.paths.processedData);

nRaw = size(rawScans, 1);
nProcessed = size(processedScans, 1);
nImported = 0;

fprintf('----- Import Pipeline -----\n');

for i = 1:nRaw

    rawPatient = rawScans{i,1};
    rawTimepoint = rawScans{i,2};
    scanPath = rawScans{i,3};

    isProcessed = is_scan_processed(cfg.paths.processedData, rawPatient, rawTimepoint);

    if isProcessed
        fprintf('Skipping %s / %s (already processed)\n', rawPatient, rawTimepoint);
        continue
    end

    fprintf('Processing %s / %s\n', rawPatient, rawTimepoint);

    % Create processed folder structure
    procPatientPath = fullfile(cfg.paths.processedData, rawPatient);
    procTimepointPath = fullfile(procPatientPath, rawTimepoint);
    importsPath = fullfile(procTimepointPath, 'imports');

    if ~exist(procPatientPath, 'dir')
        mkdir(procPatientPath);
    end

    if ~exist(procTimepointPath, 'dir')
        mkdir(procTimepointPath);
    end

    if ~exist(importsPath, 'dir')
        mkdir(importsPath);
    end

    % Group files in this scan
    groups = group_scan_dicoms(scanPath);

    % -------------------------
    % Save T2_Dixon_TE30 split by ImageType
    % -------------------------
    if ~isempty(groups.T2_Dixon_TE30)

        te30Path = fullfile(importsPath, 'T2_Dixon_TE30');
        if ~exist(te30Path, 'dir')
            mkdir(te30Path);
        end

        t2types.water = {};
        t2types.fat = {};
        t2types.IP = {};
        t2types.OP = {};

        for j = 1:length(groups.T2_Dixon_TE30)
            info = dicominfo(groups.T2_Dixon_TE30{j});

            if isfield(info, 'ImageType')
                typeLabel = classify_t2_image_type(info.ImageType);
            else
                typeLabel = 'unknown';
            end

            if isfield(t2types, typeLabel)
                t2types.(typeLabel){end+1} = groups.T2_Dixon_TE30{j};
            end
        end

        t2Labels = {'water', 'fat', 'IP', 'OP'};

        for j = 1:length(t2Labels)
            label = t2Labels{j};

            if ~isempty(t2types.(label))
                typePath = fullfile(te30Path, label);
                if ~exist(typePath, 'dir')
                    mkdir(typePath);
                end

                outputFile = fullfile(typePath, 'acquisition.mat');
                save_dicom_group(t2types.(label), outputFile);

                fprintf('  Saved T2_Dixon_TE30 / %s\n', label);
            end
        end
    end

    % -------------------------
    % Save T2_Dixon_TE50 split by ImageType
    % -------------------------
    if ~isempty(groups.T2_Dixon_TE50)

        te50Path = fullfile(importsPath, 'T2_Dixon_TE50');
        if ~exist(te50Path, 'dir')
            mkdir(te50Path);
        end

        t2types.water = {};
        t2types.fat = {};
        t2types.IP = {};
        t2types.OP = {};

        for j = 1:length(groups.T2_Dixon_TE50)
            info = dicominfo(groups.T2_Dixon_TE50{j});

            if isfield(info, 'ImageType')
                typeLabel = classify_t2_image_type(info.ImageType);
            else
                typeLabel = 'unknown';
            end

            if isfield(t2types, typeLabel)
                t2types.(typeLabel){end+1} = groups.T2_Dixon_TE50{j};
            end
        end

        t2Labels = {'water', 'fat', 'IP', 'OP'};

        for j = 1:length(t2Labels)
            label = t2Labels{j};

            if ~isempty(t2types.(label))
                typePath = fullfile(te50Path, label);
                if ~exist(typePath, 'dir')
                    mkdir(typePath);
                end

                outputFile = fullfile(typePath, 'acquisition.mat');
                save_dicom_group(t2types.(label), outputFile);

                fprintf('  Saved T2_Dixon_TE50 / %s\n', label);
            end
        end
    end

    % -------------------------
    % Save qDixon echoes
    % -------------------------
    if ~isempty(groups.qDixon_raw)
        qdixonPath = fullfile(importsPath, 'qDixon_raw');
        if ~exist(qdixonPath, 'dir')
            mkdir(qdixonPath);
        end

        echoGroups = group_qdixon_by_echo(groups.qDixon_raw);

        for e = 1:length(echoGroups)
            te = echoGroups(e).EchoTime;
            teLabel = strrep(sprintf('TE_%.3f', te), '.', 'p');

            tePath = fullfile(qdixonPath, teLabel);
            if ~exist(tePath, 'dir')
                mkdir(tePath);
            end

            outputFile = fullfile(tePath, 'acquisition.mat');
            save_dicom_group(echoGroups(e).files, outputFile);

            fprintf('  Saved qDixon_raw / %s\n', teLabel);
        end
    end

    nImported = nImported + 1;
end

fprintf('\n----- Summary -----\n');
fprintf('Raw scans detected: %d\n', nRaw);
fprintf('Processed scans detected: %d\n', nProcessed);
fprintf('New scans imported: %d\n', nImported);
fprintf('-------------------\n');
