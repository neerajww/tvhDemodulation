

function [qhd] = tvh_synthesis(qhd)
    Fs = qhd.Fs;
    Ts = 1/Fs;

    v_syn_sig = zeros(size(qhd.v_am,1),1);
    for k = 1:qhd.nharm
        v_syn_sig = v_syn_sig+qhd.v_am(:,k).*sin(cumsum(2*pi*qhd.v_fm(:,k)*Ts));
    end
    u_syn_sig = qhd.u_am.*sin(cumsum(2*pi*qhd.u_fm)*Ts);
    % ----- synthesize complete signal
    qhd.syn_sig = v_syn_sig + u_syn_sig;
    qhd.vsyn_sig = v_syn_sig;
    qhd.usyn_sig = u_syn_sig;
end
