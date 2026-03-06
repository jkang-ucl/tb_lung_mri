function tf = all_files_exist(filePaths)
% ALL_FILES_EXIST  Return true if all file paths exist.
%
% INPUT
%   filePaths - cell array of full file paths
%
% OUTPUT
%   tf        - true if every path exists as a file

tf = true;

for i = 1:length(filePaths)
    if exist(filePaths{i}, 'file') ~= 2
        tf = false;
        return
    end
end

end
