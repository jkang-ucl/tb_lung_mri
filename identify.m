inFile = "/Users/jungwookang/Documents/MATLAB.nosync/t2_mapping/DIXON MG/DICOM_BY_PROTOCOL/Enhanced/WIP_qD-Thorax_Coronal_SENSE_3.5_fa_6__921785355/IM_1610.dcm";
outDir = "/Users/jungwookang/Documents/MATLAB.nosync/t2_mapping/DIXON MG/DICOM_BY_PROTOCOL/Enhanced/WIP_qD-Thorax_Coronal_SENSE_3.5_fa_6__921785355/split_files/ECHO_ONLY";
if ~exist(outDir,"dir"), mkdir(outDir); end

% Read frames
info = dicominfo(inFile);
img  = dicomread(inFile);
V    = squeeze(img);                 % [Rows Col Frames]
nF   = double(info.NumberOfFrames);

% Extract TE per frame (Enhanced MR)
TE = nan(nF,1);
pf = info.PerFrameFunctionalGroupsSequence;
for k = 1:nF
    item = pf.(sprintf("Item_%d",k));
    if isfield(item,"MREchoSequence") && isfield(item.MREchoSequence.Item_1,"EffectiveEchoTime")
        TE(k) = double(item.MREchoSequence.Item_1.EffectiveEchoTime);
    end
end

% Keep only echo frames (TE>0)
epsTE = 1e-6;
isEcho = ~isnan(TE) & (TE > epsTE);

V_echo  = V(:,:,isEcho);             % [Rows Col 540]
TE_echo = TE(isEcho);                % [540 x 1]

% Identify the 6 echo times
uTE = unique(TE_echo);
uTE = sort(uTE(:));                  % 6 x 1 expected
fprintf("Unique echo TEs (ms): "); fprintf("%.3f ", uTE); fprintf("\n");

nEcho = numel(uTE);
if nEcho ~= 6
    warning("Expected 6 echoes, found %d. Proceeding anyway.", nEcho);
end

% Split frames by TE and reshape to [Rows Col Slices Echoes]
idxByEcho = cell(nEcho,1);
for e = 1:nEcho
    idxByEcho{e} = find(abs(TE_echo - uTE(e)) < 1e-6);
end

% Sanity: all echoes should have same number of slices
nPerEcho = cellfun(@numel, idxByEcho);
disp(table(uTE, nPerEcho, 'VariableNames', ["TE_ms","FramesPerEcho"]))

if numel(unique(nPerEcho)) ~= 1
    error("Echo groups have different frame counts. Check ordering/metadata.");
end

nSlice = nPerEcho(1);
V4 = zeros(size(V,1), size(V,2), nSlice, nEcho, class(V));

for e = 1:nEcho
    V4(:,:,:,e) = V_echo(:,:,idxByEcho{e});
end

% Save for analysis
save(fullfile(outDir,"echoes.mat"), "V4", "uTE", "-v7.3");
disp("Saved: " + fullfile(outDir,"echoes.mat"));
disp("V4 size = " + mat2str(size(V4)));
