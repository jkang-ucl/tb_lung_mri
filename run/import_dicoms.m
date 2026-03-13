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

    %% Create processed folder structure

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


    %% Create analysis folder structure (NEW)

    analysisPatientPath = fullfile(cfg.paths.analysisData, rawPatient);
    analysisTimepointPath = fullfile(analysisPatientPath, rawTimepoint);

    if ~exist(analysisPatientPath, 'dir')
        mkdir(analysisPatientPath);
    end

    if ~exist(analysisTimepointPath, 'dir')
        mkdir(analysisTimepointPath);
    end


    %% Group files in this scan

    groups = group_scan_dicoms(scanPath);


    %% -------------------------
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

        t2Labels = {'water','fat','IP','OP'};

        for j = 1:length(t2Labels)

            label = t2Labels{j};

            if ~isempty(t2types.(label))

                typePath = fullfile(te30Path,label);

                if ~exist(typePath,'dir')
                    mkdir(typePath);
                end

                outputFile = fullfile(typePath,'acquisition.mat');

                save_dicom_group(t2types.(label),outputFile);

                fprintf('  Saved T2_Dixon_TE30 / %s\n',label);

            end
        end
    end


    %% -------------------------
    % Save T2_Dixon_TE50 split by ImageType
    % -------------------------

    if ~isempty(groups.T2_Dixon_TE50)

        te50Path = fullfile(importsPath,'T2_Dixon_TE50');

        if ~exist(te50Path,'dir')
            mkdir(te50Path);
        end

        t2types.water = {};
        t2types.fat = {};
        t2types.IP = {};
        t2types.OP = {};

        for j = 1:length(groups.T2_Dixon_TE50)

            info = dicominfo(groups.T2_Dixon_TE50{j});

            if isfield(info,'ImageType')
                typeLabel = classify_t2_image_type(info.ImageType);
            else
                typeLabel = 'unknown';
            end

            if isfield(t2types,typeLabel)
                t2types.(typeLabel){end+1} = groups.T2_Dixon_TE50{j};
            end

        end

        t2Labels = {'water','fat','IP','OP'};

        for j = 1:length(t2Labels)

            label = t2Labels{j};

            if ~isempty(t2types.(label))

                typePath = fullfile(te50Path,label);

                if ~exist(typePath,'dir')
                    mkdir(typePath);
                end

                outputFile = fullfile(typePath,'acquisition.mat');

                save_dicom_group(t2types.(label),outputFile);

                fprintf('  Saved T2_Dixon_TE50 / %s\n',label);

            end
        end
    end


    %% -------------------------
    % Save qDixon echoes
    % -------------------------

    if ~isempty(groups.qDixon_raw)

        qdixonPath = fullfile(importsPath,'qDixon_raw');

        if ~exist(qdixonPath,'dir')
            mkdir(qdixonPath);
        end

        echoGroups = group_qdixon_by_echo(groups.qDixon_raw);

        echoVolumes = cell(1,length(echoGroups));
        echoTimes = zeros(1,length(echoGroups));
        refAcq = [];

        for e = 1:length(echoGroups)

            te = echoGroups(e).EchoTime;
            echoTimes(e) = te;

            teLabel = strrep(sprintf('TE_%.3f',te),'.','p');

            tePath = fullfile(qdixonPath,teLabel);

            if ~exist(tePath,'dir')
                mkdir(tePath);
            end

            outputFile = fullfile(tePath,'acquisition.mat');

            save_dicom_group(echoGroups(e).files,outputFile);

            tmp = load(outputFile);
            echoVolumes{e} = tmp.acquisition.volume;

            if isempty(refAcq)
                refAcq = tmp.acquisition;
            end

            fprintf('  Saved qDixon_raw / %s\n',teLabel);

        end


        %% Sort echoes

        [echoTimes,sortIdx] = sort(echoTimes);
        echoVolumes = echoVolumes(sortIdx);


        %% Verify dimensions

        refSize = size(echoVolumes{1});

        for e = 2:length(echoVolumes)

            if ~isequal(size(echoVolumes{e}),refSize)
                error('Echo volume size mismatch between echoes.');
            end

        end


        %% Build MAGORINO 5D array

        nx = refSize(1);
        ny = refSize(2);
        nz = refSize(3);
        nEchoes = length(echoVolumes);

        images = zeros(nx, ny, nz, 1, nEchoes, 'single');

        for e = 1:nEchoes
            images(:,:,:,1,e) = single(echoVolumes{e});
        end


        %% Build imData struct

        imData = struct();

        imData.images = images;

        % TE as 1 x n row vector in seconds
        imData.TE = echoTimes(:)' / 1000;

        if isfield(refAcq,'fieldStrength')
            imData.FieldStrength = double(refAcq.fieldStrength);
        elseif isfield(refAcq,'magneticFieldStrength')
            imData.FieldStrength = double(refAcq.magneticFieldStrength);
        else
            warning('Field strength not found; set manually later.');
            imData.FieldStrength = [];
        end

        imData.protocolName = refAcq.protocolName;

        % Default MAGORINO setting
        imData.fittingIndent = 0;

        % Useful metadata
        imData.nEchoes = nEchoes;
        imData.size = size(images);


        %% Store metadata

        imData.patientID = rawPatient;
        imData.timepoint = rawTimepoint;

        imData.paths.processedRoot = cfg.paths.processedData;
        imData.paths.analysisRoot = cfg.paths.analysisData;
        imData.paths.importsPath = qdixonPath;


        %% Save MAGORINO input

        save(fullfile(qdixonPath,'magorino_imData.mat'),'imData','-v7.3');

        fprintf('  Saved MAGORINO-compatible imData\n');

    end


    nImported = nImported + 1;

end


fprintf('\n----- Summary -----\n');
fprintf('Raw scans detected: %d\n',nRaw);
fprintf('Processed scans detected: %d\n',nProcessed);
fprintf('New scans imported: %d\n',nImported);
fprintf('-------------------\n');
