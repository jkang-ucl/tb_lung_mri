function dicoms = load_scan_dicoms(scanPath)
% LOAD_SCAN_DICOMS  Load all DICOM files from one scan folder.
%
% INPUT
%   scanPath - path to one scan folder, e.g.
%              RawDICOM/Patient001/TP1
%
% OUTPUT
%   dicoms   - struct array with one element per DICOM file
%              dicoms(i).filename
%              dicoms(i).info
%              dicoms(i).image

files = dir(scanPath);
files = files(~[files.isdir]);
disp(files)
nFiles = length(files);
dicoms = struct('filename', {}, 'info', {}, 'image', {});

for i = 1:nFiles
    filePath = fullfile(scanPath, files(i).name);

    dicoms(i).filename = files(i).name;
    dicoms(i).info = dicominfo(filePath);
    dicoms(i).image = dicomread(filePath);
end

end
