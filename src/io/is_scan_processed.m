function tf = is_scan_processed(processedRoot, patientID, timepoint)
% IS_SCAN_PROCESSED  Determine whether a scan has been fully imported.

importsPath = fullfile(processedRoot, patientID, timepoint, 'imports');

requiredFiles = {
    fullfile(importsPath, 'T2_Dixon_TE30', 'water', 'acquisition.mat')
    fullfile(importsPath, 'T2_Dixon_TE50', 'water', 'acquisition.mat')

    fullfile(importsPath, 'qDixon_raw', 'TE_1p037', 'acquisition.mat')
    fullfile(importsPath, 'qDixon_raw', 'TE_1p817', 'acquisition.mat')
    fullfile(importsPath, 'qDixon_raw', 'TE_2p598', 'acquisition.mat')
    fullfile(importsPath, 'qDixon_raw', 'TE_3p378', 'acquisition.mat')
    fullfile(importsPath, 'qDixon_raw', 'TE_4p158', 'acquisition.mat')
    fullfile(importsPath, 'qDixon_raw', 'TE_4p939', 'acquisition.mat')

    % NEW: combined MAGORINO dataset
    fullfile(importsPath, 'qDixon_raw', 'magorino_imData.mat')
};

tf = all_files_exist(requiredFiles);

end
