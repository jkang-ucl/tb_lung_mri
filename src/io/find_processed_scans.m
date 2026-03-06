function scans = find_processed_scans(processedRoot)
% FIND_PROCESSED_SCANS  Discover all processed scan sessions.
%
% INPUT
%   processedRoot  - path to the Processed root directory
%
% OUTPUT
%   scans          - cell array:
%                    {patientID, timepoint, scanPath}

scans = {};
patients = dir(processedRoot);

for p = 1:length(patients)
    patientName = patients(p).name;
    if patients(p).isdir && ~startsWith(patientName, '.')
        patientPath = fullfile(processedRoot, patientName);
        timepoints = dir(patientPath);
        for t = 1:length(timepoints)
            tpName = timepoints(t).name;
            if timepoints(t).isdir && ~startsWith(tpName, '.')
                tpPath = fullfile(patientPath, tpName);
                scans(end+1, :) = {patientName, tpName, tpPath};
            end
        end
    end
end

end
