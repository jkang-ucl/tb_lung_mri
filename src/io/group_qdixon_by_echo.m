function echoGroups = group_qdixon_by_echo(qFiles)
% GROUP_QDIXON_BY_ECHO  Group qDixon raw DICOM files by EchoTime.
%
% INPUT
%   qFiles - cell array of file paths belonging to qDixon_raw
%
% OUTPUT
%   echoGroups - struct array with fields:
%                .EchoTime
%                .files
%
%                Each element corresponds to one echo time.

echoTimes = [];
% First pass: collect echo times
for i = 1:length(qFiles)
    info = dicominfo(qFiles{i});
    if isfield(info,'EchoTime')
        echoTimes(end+1) = info.EchoTime;
    end
end

uniqueTE = unique(echoTimes);

% Remove TE = 0
uniqueTE(uniqueTE == 0) = [];
echoGroups = struct('EchoTime',{},'files',{});

for e = 1:length(uniqueTE)
    TE = uniqueTE(e);
    filesForEcho = {};
    for i = 1:length(qFiles)
        info = dicominfo(qFiles{i});
        if isfield(info,'EchoTime')
            if abs(info.EchoTime - TE) < 1e-4
                filesForEcho{end+1} = qFiles{i};
            end
        end
    end

    echoGroups(e).EchoTime = TE;
    echoGroups(e).files = filesForEcho;

end

end
