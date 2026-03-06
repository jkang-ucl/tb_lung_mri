function label = classify_protocol_name(protocolName)
% CLASSIFY_PROTOCOL_NAME  Map scanner ProtocolName to project acquisition label.

if contains(protocolName, 'T2W_TSE_DIXON_TE30')
    label = 'T2_Dixon_TE30';

elseif contains(protocolName, 'T2W_TSE_DIXON_TE50')
    label = 'T2_Dixon_TE50';

elseif contains(protocolName, 'WIP qD-Thorax')
    label = 'qDixon_raw';

else
    label = 'ignore';
end

end
