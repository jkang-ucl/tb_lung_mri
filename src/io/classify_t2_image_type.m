function label = classify_t2_image_type(imageType)
% CLASSIFY_T2_IMAGE_TYPE  Map DICOM ImageType to Dixon image label.

if contains(imageType, '\W\W\')
    label = 'water';

elseif contains(imageType, '\F\F\')
    label = 'fat';

elseif contains(imageType, '\IP\IP\')
    label = 'IP';

elseif contains(imageType, '\OP\OP\')
    label = 'OP';

else
    label = 'unknown';
end

end
