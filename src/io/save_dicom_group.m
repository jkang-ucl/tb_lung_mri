function save_dicom_group(filePaths, outputFile)
% SAVE_DICOM_GROUP  Save one DICOM group into a clean MATLAB structure.
%
% INPUT
%   filePaths   - cell array of DICOM file paths
%   outputFile  - full path to output .mat file
%
% OUTPUT
%   Saves a struct called "acquisition"

nFiles = length(filePaths);

infoList = cell(nFiles, 1);
imageList = cell(nFiles, 1);
instanceNumbers = zeros(nFiles, 1);
sliceLocations = nan(nFiles, 1);
zPositions = nan(nFiles, 1);
imagePositionPatient = nan(nFiles, 3);

for i = 1:nFiles
    infoList{i} = dicominfo(filePaths{i});
    imageList{i} = dicomread(filePaths{i});

    if isfield(infoList{i}, 'InstanceNumber')
        instanceNumbers(i) = double(infoList{i}.InstanceNumber);
    else
        instanceNumbers(i) = i;
    end

    if isfield(infoList{i}, 'SliceLocation')
        sliceLocations(i) = double(infoList{i}.SliceLocation);
    end

    if isfield(infoList{i}, 'ImagePositionPatient')
        pos = double(infoList{i}.ImagePositionPatient(:));
        if numel(pos) == 3
            imagePositionPatient(i, :) = pos.';
            zPositions(i) = pos(3);
        end
    end
end

% Sort by InstanceNumber
[instanceNumbers, sortIdx] = sort(instanceNumbers);
filePaths = filePaths(sortIdx);
infoList = infoList(sortIdx);
imageList = imageList(sortIdx);
sliceLocations = sliceLocations(sortIdx);
imagePositionPatient = imagePositionPatient(sortIdx, :);
zPositions = zPositions(sortIdx);

% Stack into 3D volume
firstImage = imageList{1};
[rows, cols] = size(firstImage);
volume = zeros(rows, cols, nFiles, class(firstImage));

for i = 1:nFiles
    volume(:, :, i) = imageList{i};
end

firstInfo = infoList{1};

acquisition = struct();

% Core data
acquisition.volume = volume;
acquisition.filePaths = filePaths;
acquisition.info = infoList;

% Indexing / geometry
acquisition.instanceNumbers = instanceNumbers;
acquisition.sliceLocations = sliceLocations;
acquisition.imagePositionPatient = imagePositionPatient;
acquisition.zPositions = zPositions;

% Basic dimensions
acquisition.rows = rows;
acquisition.cols = cols;
acquisition.nSlices = nFiles;

% Common metadata
if isfield(firstInfo, 'ProtocolName')
    acquisition.protocolName = firstInfo.ProtocolName;
else
    acquisition.protocolName = '';
end

if isfield(firstInfo, 'EchoTime')
    acquisition.echoTime = double(firstInfo.EchoTime);
else
    acquisition.echoTime = [];
end

if isfield(firstInfo, 'SeriesNumber')
    acquisition.seriesNumber = double(firstInfo.SeriesNumber);
else
    acquisition.seriesNumber = [];
end

if isfield(firstInfo, 'ImageType')
    acquisition.imageType = firstInfo.ImageType;
else
    acquisition.imageType = '';
end

if isfield(firstInfo, 'PixelSpacing')
    acquisition.pixelSpacing = double(firstInfo.PixelSpacing(:));
else
    acquisition.pixelSpacing = [];
end

if isfield(firstInfo, 'SliceThickness')
    acquisition.sliceThickness = double(firstInfo.SliceThickness);
else
    acquisition.sliceThickness = [];
end

if isfield(firstInfo, 'SpacingBetweenSlices')
    acquisition.spacingBetweenSlices = double(firstInfo.SpacingBetweenSlices);
else
    acquisition.spacingBetweenSlices = [];
end

if isfield(firstInfo, 'ImageOrientationPatient')
    acquisition.imageOrientationPatient = double(firstInfo.ImageOrientationPatient(:));
else
    acquisition.imageOrientationPatient = [];
end

if isfield(firstInfo, 'RescaleSlope')
    acquisition.rescaleSlope = double(firstInfo.RescaleSlope);
else
    acquisition.rescaleSlope = [];
end

if isfield(firstInfo, 'RescaleIntercept')
    acquisition.rescaleIntercept = double(firstInfo.RescaleIntercept);
else
    acquisition.rescaleIntercept = [];
end

if isfield(firstInfo, 'RepetitionTime')
    acquisition.repetitionTime = double(firstInfo.RepetitionTime);
else
    acquisition.repetitionTime = [];
end

if isfield(firstInfo, 'FlipAngle')
    acquisition.flipAngle = double(firstInfo.FlipAngle);
else
    acquisition.flipAngle = [];
end

if isfield(firstInfo, 'Manufacturer')
    acquisition.manufacturer = firstInfo.Manufacturer;
else
    acquisition.manufacturer = '';
end

if isfield(firstInfo, 'ManufacturerModelName')
    acquisition.manufacturerModelName = firstInfo.ManufacturerModelName;
else
    acquisition.manufacturerModelName = '';
end

if isfield(firstInfo, 'MagneticFieldStrength')
    acquisition.magneticFieldStrength = double(firstInfo.MagneticFieldStrength);
else
    acquisition.magneticFieldStrength = [];
end

save(outputFile, 'acquisition');

end
