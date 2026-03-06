function [V, infos, meta] = load_dicom_series(folder)
%LOAD_DICOM_SERIES Load a DICOM series folder into a 3D volume (single).
%   Works without Image Processing Toolbox functions like dicomreadVolume.

    files = dir(fullfile(folder, "*.dcm"));
    if isempty(files)
        files = dir(fullfile(folder, "*")); % fallback
        files = files(~[files.isdir]);
        files = files(endsWith(string({files.name}), [".dcm",".DCM"], "IgnoreCase", true));
    end
    assert(~isempty(files), "No DICOM files found in: %s", folder);

    n = numel(files);
    infos = cell(n,1);

    z = nan(n,1);
    ipp = nan(n,3);

    % Read metadata and decide sorting key
    for i = 1:n
        p = fullfile(folder, files(i).name);
        infos{i} = dicominfo(p);

        if isfield(infos{i}, "ImagePositionPatient")
            ipp(i,:) = double(infos{i}.ImagePositionPatient(:))';
            z(i) = ipp(i,3);
        elseif isfield(infos{i}, "SliceLocation")
            z(i) = double(infos{i}.SliceLocation);
        else
            z(i) = i; % last resort
        end
    end

    % Sort by slice position
    [~, idx] = sort(z, "ascend");
    infos = infos(idx);
    files = files(idx);

    % Read first slice to preallocate
    firstPath = fullfile(folder, files(1).name);
    I0 = dicomread(firstPath);
    I0 = single(I0);

    V = zeros([size(I0,1), size(I0,2), n], "single");

    % Apply rescale if present
    for i = 1:n
        p = fullfile(folder, files(i).name);
        I = single(dicomread(p));

        rs = 1; ri = 0;
        if isfield(infos{i}, "RescaleSlope"),     rs = single(infos{i}.RescaleSlope); end
        if isfield(infos{i}, "RescaleIntercept"), ri = single(infos{i}.RescaleIntercept); end
        V(:,:,i) = I * rs + ri;
    end

    % Some helpful metadata
    meta = struct();
    meta.Rows = size(V,1);
    meta.Cols = size(V,2);
    meta.Slices = size(V,3);
    meta.EchoTime_ms = getfield_safe(infos{1}, "EchoTime", NaN);
    meta.RepetitionTime_ms = getfield_safe(infos{1}, "RepetitionTime", NaN);
    meta.SeriesDescription = getfield_safe(infos{1}, "SeriesDescription", "");
end

function v = getfield_safe(s, f, default)
    if isfield(s,f), v = s.(f); else, v = default; end
end
