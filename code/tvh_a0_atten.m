

function [sub_f0sigs] = tvh_a0_atten(sub_sigs,qhd,Fs)

Ts = 1/Fs;
for i = 1:length(qhd.a0_atten)
    sub_f0sigs(i) = sub_sigs;
    v_syn_sig = zeros(size(sub_sigs.v_am,1),1);
    for k = 1:qhd.nharm
        sub_f0sigs(i).v_fm(:,k) = sub_sigs.v_fm(:,k);
        if k == 1
        indx = sub_sigs.v_am(:,k)>0.; 
% to change the magnitude of variations via exponentiation
%         mu_am = mean(sub_sigs.v_am(indx,k));
%         sub_f0sigs(i).v_am(indx,k) = mu_am*exp(qhd.a0_atten(i)*log(sub_sigs.v_am(indx,k)/mu_am));
%         else
%         sub_f0sigs(i).v_am(:,k) = sub_sigs.v_am(:,k);
%         end

% to change the correlations of a0 with rest
%         len = size(sub_sigs.v_fm,1);
%         temp = randn(len,1);
%         temp2 = zeros(len,1);
%         fc = 10;
%         L = fix(1/fc*20*Fs);
%         h = fir1(L,fc*2 /Fs);
%         temp1 = freq_filtering(temp,h,qhd.ftimes);
%         
%         temp2(indx) = temp1(indx);
%         temp2 = 0.5*temp2/max(abs(temp2));
%         sub_f0sigs(i).v_am(indx,k) = sub_sigs.v_am(indx,k)+qhd.a0_atten(i)*temp2(indx);

% to change the magnitude of variations via exponentiation
        mu_am = mean(sub_sigs.v_am(indx,k));
        if qhd.a0_atten(i) == -1
        sub_f0sigs(i).v_am(indx,k) = mu_am;
        else
        sub_f0sigs(i).v_am(:,k) = qhd.a0_atten(i)*sub_sigs.v_am(:,k);
        end
        else
        sub_f0sigs(i).v_am(:,k) = qhd.a0_atten(i)*sub_sigs.v_am(:,k);
        end
    end
    
    % ----- synthesize am and fm voiced
    for k = 1:qhd.nharm
    v_syn_sig = v_syn_sig+sub_f0sigs(i).v_am(:,k).*sin(cumsum(2*pi*sub_f0sigs(i).v_fm(:,k)*Ts));
    end
    
    % ----- synthesize unvoiced
    sub_f0sigs(i).u_am = sub_sigs.u_am;
    sub_f0sigs(i).u_fm = sub_sigs.u_fm;

    u_syn_sig = sub_f0sigs(i).u_am.*sin(cumsum(2*pi*sub_f0sigs(i).u_fm)*Ts);
    sub_f0sigs(i).syn_qhd = v_syn_sig + u_syn_sig; 
end