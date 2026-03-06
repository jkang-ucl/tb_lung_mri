src = "/Users/jungwookang/Documents/MATLAB.nosync/t2_mapping/DIXON MG/DICOM";
dst = "/Users/jungwookang/Documents/MATLAB.nosync/t2_mapping/DIXON MG/DICOM_BY_PROTOCOL";

T = dicomCollection(src,"IncludeSubfolders",true);

safe = @(s) regexprep(string(s),'[^A-Za-z0-9._-]','_');

nFiles = cellfun(@numel, T.Filenames);
isEnhanced = (nFiles == 1) & (T.Frames > 1) & (T.Rows > 0);
isPR = (T.Modality == "PR") | (T.Rows == 0) | (T.Columns == 0);

vars = lower(string(T.Properties.VariableNames));
hasSeriesNumber = any(vars=="seriesnumber");

for i = 1:height(T)

    % --- bucket ---
    if isPR(i)
        bucket = "PR";
    elseif isEnhanced(i)
        bucket = "Enhanced";
    else
        bucket = "Classic";
    end

    % --- read ProtocolName from one object in the series ---
    files = string(T.Filenames{i});
    info  = dicominfo(files(1));

    if isfield(info,"ProtocolName") && strlength(strtrim(string(info.ProtocolName))) > 0
        proto = string(info.ProtocolName);
    else
        proto = "Protocol";
    end

    % --- series number (optional, nice to have) ---
    serNo = "";
    if hasSeriesNumber && ~ismissing(T.SeriesNumber(i))
        serNo = "SN" + string(T.SeriesNumber(i));
    end

    % --- UID suffix (guarantees uniqueness) ---
    uid = string(T.SeriesInstanceUID(i));
    if strlength(uid) > 10
        uid = extractAfter(uid, strlength(uid) - 9);
    end

    folderName = safe(proto);
    if strlength(serNo) > 0
        folderName = folderName + "__" + safe(serNo);
    end
    folderName = folderName + "__" + safe(uid);

    outDir = fullfile(dst, bucket, folderName);
    if ~exist(outDir,"dir"), mkdir(outDir); end

    % --- copy files ---
    for k = 1:numel(files)
        inFile = files(k);
        [~,name,ext] = fileparts(inFile);
        if ext == "", ext = ".dcm"; end
        copyfile(inFile, fullfile(outDir, name + ext));
    end
end

disp("Done. Folders named by ProtocolName in: " + dst);
