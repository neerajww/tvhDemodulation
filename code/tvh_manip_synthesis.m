


function [qhd] = tvh_manip_synthesis(qhd)
    Fs = qhd.Fs;
    Ts = 1/Fs;
    
    % original signal
    v_syn_sig = zeros(size(qhd.v_am,1),1);
    
    for k = 1:qhd.nharm
        v_syn_sig = v_syn_sig+qhd.v_am(:,k).*sin(cumsum(2*pi*qhd.v_fm(:,k)*Ts));
    end
    
    u_syn_sig = qhd.u_am.*sin(cumsum(2*pi*qhd.u_fm)*Ts);
    % ----- synthesize complete signal
    qhd.syn_sig = v_syn_sig + u_syn_sig;
    qhd.vsyn_sig = v_syn_sig;
    qhd.usyn_sig = u_syn_sig;
    
    
    % manipulated signal
    v_syn_sig = zeros(size(qhd.new_v_am,1),1);
    for k = 1:qhd.nharm
        v_syn_sig = v_syn_sig+qhd.new_v_am(:,k).*sin(cumsum(2*pi*qhd.new_v_fm(:,k)*Ts));
    end
    u_syn_sig = qhd.new_u_am.*sin(cumsum(2*pi*qhd.new_u_fm)*Ts);
    % ----- synthesize complete signal
    qhd.new_syn_sig = v_syn_sig + u_syn_sig;
    qhd.new_vsyn_sig = v_syn_sig;
    qhd.new_usyn_sig = u_syn_sig;    
end
