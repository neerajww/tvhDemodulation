

function [sub_sigs] = tvh_synthesis(sub_sigs,qhd,Fs)

Ts = 1/Fs;
v_syn_sig = zeros(size(sub_sigs.v_am,1),1);
% ----- synthesize am and fm voiced
for k = 1:qhd.nharm
    v_syn_sig = v_syn_sig+sub_sigs.v_am(:,k).*sin(cumsum(2*pi*sub_sigs.v_fm(:,k)*Ts));
end

u_syn_sig = sub_sigs.u_am.*sin(cumsum(2*pi*sub_sigs.u_fm)*Ts);

% ----- synthesize complete signal
sub_sigs.syn_qhd = v_syn_sig + u_syn_sig; 

end
