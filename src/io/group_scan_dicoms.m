function groups = group_scan_dicoms(scanPath)
% GROUP_SCAN_DICOMS  Group DICOM files in one scan folder by acquisition label.
%
% INPUT
%   scanPath - path to one timepoint folder, e.g.
%              RawDICOM/Patient001/TP1
%
% OUTPUT
%   groups   - struct with fields:
%              groups.T2_Dixon_TE30
%              groups.T2_Dixon_TE50
%              groups.qDixon_raw
%
%              Each field contains a cell array of file paths.

files = dir(scanPath);
files = files(~[files.isdir]);

groups.T2_Dixon_TE30 = {};
groups.T2_Dixon_TE50 = {};
groups.qDixon_raw = {};

for i = 1:length(files)

    filePath = fullfile(scanPath, files(i).name);
    info = dicominfo(filePath);

    if isfield(info, 'ProtocolName')
        label = classify_protocol_name(info.ProtocolName);
    else
        label = 'ignore';
    end

    if strcmp(label, 'T2_Dixon_TE30')
        groups.T2_Dixon_TE30{end+1} = filePath;

    elseif strcmp(label, 'T2_Dixon_TE50')
        groups.T2_Dixon_TE50{end+1} = filePath;

    elseif strcmp(label, 'qDixon_raw')
        groups.qDixon_raw{end+1} = filePath;
    end

end

end
