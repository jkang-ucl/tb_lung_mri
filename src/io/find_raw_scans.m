function scans = find_raw_scans(rawRoot)
% FIND_RAW_DICOMS  Discover all scan sessions in the RawDICOM folder.
%
% INPUT
%   rawRoot  - string or char
%              Path to the RawDICOM root directory.
%
%              Expected folder structure:
%              RawDICOM/
%                  PatientID/
%                      TP1/
%                      TP2/
%
% OUTPUT
%   scans    - cell array where each row represents one scan session:
%
%              {patientID, timepoint, scanPath}
%
%              Example output:
%              {
%                  'Patient001', 'TP1', '/.../RawDICOM/Patient001/TP1'
%                  'Patient001', 'TP2', '/.../RawDICOM/Patient001/TP2'
%              }
%
% DESCRIPTION
%   This function scans the RawDICOM directory and identifies all
%   available patient/timepoint scan folders. It does not read any
%   DICOM files yet; it only identifies scan sessions available
%   for later processing.
%
%   This is the first stage of the DICOM import pipeline.

scans = {};
patients = dir(rawRoot);

for p = 1:length(patients)
    patientName = patients(p).name;
    if patients(p).isdir && ~startsWith(patientName,'.')
        patientPath = fullfile(rawRoot, patientName);
        timepoints = dir(patientPath);
        for t = 1:length(timepoints)
            tpName = timepoints(t).name;
            if timepoints(t).isdir && ~startsWith(tpName,'.')
                tpPath = fullfile(patientPath, tpName);
                scans(end+1,:) = {patientName, tpName, tpPath};
            end
        end
    end
end

end
