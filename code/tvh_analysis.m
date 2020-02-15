
function [qhd] = tvh_analysis(qhd)

% ----- inits
Fs = qhd.Fs;
f0 = qhd.f0;

% ----- inits
v_fm = cell(1,qhd.iq_times);
v_am = cell(1,qhd.iq_times);

Ts = 1/Fs;
len = length(qhd.x);
x_orig = qhd.x;

% ----- ----- refine and estimate IA/IF of FFS via IQ
fm_est(:,1) = f0;
fm_est(:,2) = fm_est;
am_est = zeros(len,2);
for i = 1:qhd.iq_times
    
    % ----- find the phase delay using IQ
    in_ph_sig = sin(cumsum(2*pi*fm_est(:,2))*Ts);
    qu_ph_sig = cos(cumsum(2*pi*fm_est(:,2))*Ts);

    % ----- IQ components
    coh_1 = 2*x_orig.*in_ph_sig;
    coh_2 = 2*x_orig.*qu_ph_sig;

    % ----- lpf IQ components to estimate IA
    if 1
    L = fix(1/qhd.vBW_am*5*Fs);
    h = fir1(L,qhd.vBW_am*2 /Fs);
    if 0%do_plot_filter_resp
    nfft = 2^(nextpow2(L)+1);
    H = fft(h,nfft);
    faxis = (0:nfft/2-1)*Fs/nfft;
    figure; plot(faxis,20*log10(abs(H(1:length(faxis)))/max(abs(H(1:length(faxis))))));
    end
    
    bb_coh_1 = freq_filtering(coh_1,h,qhd.ftimes);
    bb_coh_2 = freq_filtering(coh_2,h,qhd.ftimes);
    
    if i == 1
    am_est(:,1) = sqrt(bb_coh_1.^2+bb_coh_2.^2);
    am_est(:,2) = am_est(:,1);
    else
    am_est(:,2) = sqrt(bb_coh_1.^2+bb_coh_2.^2);
    end        
    pm_corr = (atan(bb_coh_2./bb_coh_1));
    pm_corr(isnan(pm_corr)) = 0;
    % ----- update IF
    if i<qhd.iq_times
    fm_est(:,2) = fm_est(:,2)+medfilt1([diff(unwrap(pm_corr))/Ts/2/pi;0],5);
    L = fix(1/qhd.vBW_fm*5*Fs);
    h = fir1(L,qhd.vBW_fm*2 /Fs);
    fm_est(:,2) = freq_filtering(fm_est(:,2),h,qhd.ftimes); 
    end
    fm_est(find(fm_est(:,2)<50),2) = 10;
    end
end

% ----- V/UV streaming
uv_indx = find(am_est(:,2)<qhd.nu*max(am_est(:,2)) | fm_est(:,2)<30); 
v_mask = ones(len,1); v_mask(uv_indx,1) = 0;
uv_mask = zeros(len,1); uv_mask(uv_indx,1) = 1;


v_fm_est = fm_est(:,2);
v_fm_est(uv_indx,1) = 0;

v_am_est = am_est(:,2);
v_am_est(uv_indx,1) = 0;

ux_orig = zeros(len,1);
ux_orig(uv_indx) = x_orig(uv_indx);

% ----- unvoiced IA/IF estimation
hux = hilbert(ux_orig);
u_am_est = uv_mask.*abs(hux);
u_pm_est = uv_mask.*angle(hux);
u_fm_est = [-diff(unwrap(u_pm_est))/Ts/2/pi; zeros(1,1)];

% ----- LPF unvoiced IA and IF 
ufc_am = qhd.uBW_am(1);
%    L = fix(len/100)+1;
L = fix(1/ufc_am*20*Fs);
h = fir1(L,ufc_am*2 /Fs);
if 0
nfft = 2^(nextpow2(L)+1);
H = fft(h,nfft);
faxis = (0:nfft/2-1)*Fs/nfft;
figure; plot(faxis,20*log10(abs(H(1:length(faxis)))/max(abs(H(1:length(faxis))))));
end

u_am_est = freq_filtering(u_am_est,h,qhd.ftimes);

ufc_fm = qhd.uBW_fm(1);
%    L = fix(len/100)+1;
L = fix(1/ufc_fm*20*Fs);
h = fir1(L,ufc_fm*2 /Fs);
if 0
nfft = 2^(nextpow2(L)+1);
H = fft(h,nfft);
faxis = (0:nfft/2-1)*Fs/nfft;
figure; plot(faxis,20*log10(abs(H(1:length(faxis)))/max(abs(H(1:length(faxis))))));
end
u_fm_est = freq_filtering(u_fm_est,h,qhd.ftimes);

u_am = u_am_est;
u_fm = u_fm_est;


% ----- filter out each harmonic from voiced signal
%med_vfmest = median(v_fm_est(v_fm_est>0));
% nharm = fix(6e3/med_vfmest);
%              nharm = 20;
qhd.nharm = fix(7e3/median(v_fm_est(v_mask>0,1)));
%display(qhd.nharm)
for i = 1:qhd.iq_times
v_am{i} = zeros(length(x_orig),qhd.nharm);
v_fm{i} = zeros(length(x_orig),qhd.nharm);
end

for i = 1:qhd.iq_times
v_am{i}(:,1) = v_am_est;
v_fm{i}(:,1) = v_fm_est;
end

vfc_am = qhd.vBW_am(1); 
vfc_fm = qhd.vBW_fm(1); 

% qhd.nharm = fix(4.0e3/median(v_fm{1}(v_mask>0,1)));
qhd.nharm = fix(7e3/median(v_fm{1}(v_mask>0,1)));
display(['Number of harmonic used (updated): ' num2str(qhd.nharm)])
for i = 2:qhd.nharm
    v_fm{1}(:,i) = i*v_fm{1}(:,1);
    for j = 1:qhd.iq_times
        
        v_fm{j}(v_fm{j}(:,i)>Fs/2,i) = Fs/2;
        in_ph_sig = sin(cumsum(2*pi*v_fm{j}(:,i))*Ts);
        qu_ph_sig = cos(cumsum(2*pi*v_fm{j}(:,i))*Ts);
        
        coh_1 = 2*x_orig.*in_ph_sig.*v_mask+eps;
        coh_2 = 2*x_orig.*qu_ph_sig.*v_mask+eps;
        
        % ----- lpf
    %     L = fix(len/10)+1;
        L = fix(1/vfc_am*5*Fs/2);
        h = fir1(L,vfc_am*2 /Fs);
        if 0%do_plot_filter_resp
            nfft = 2^(nextpow2(L)+1);
            H = fft(h,nfft);
            faxis = (0:nfft/2-1)*Fs/nfft;
            figure; plot(faxis,20*log10(abs(H(1:length(faxis)))/max(abs(H(1:length(faxis))))));
        end
        bb_coh_1 = freq_filtering(coh_1,h,qhd.ftimes)';
        bb_coh_2 = freq_filtering(coh_2,h,qhd.ftimes)';
        % ----- envelope
        v_am{j}(:,i) = sqrt(bb_coh_1.^2+bb_coh_2.^2);
        pm_corr = (atan(bb_coh_2./bb_coh_1))';

        % ----- update IF
        if j<qhd.iq_times
        v_fm{j+1}(:,i) = v_fm{j}(:,i)+medfilt1([diff(unwrap(pm_corr))/Ts/2/pi;0],5);

        L = fix(1/vfc_fm*5*Fs/2);
        h = fir1(L,vfc_fm*2 /Fs);
        v_fm{j+1}(:,i) = freq_filtering(v_fm{j+1}(:,i),h,qhd.ftimes); 
        v_fm{j+1}(find(v_fm{j+1}(:,i)<50),i) = 0;
        end
    end
    v_fm{qhd.iq_times}(find(v_fm{qhd.iq_times}(:,i)<50),i) = 0;
end
    
% ----- synthesize voiced
v_syn_sig = zeros(length(x_orig),1);
for j = 1:qhd.nharm
    zero_mask = v_fm{qhd.iq_times}(:,j)<7e3;
    v_syn_sig = v_syn_sig+zero_mask.*v_am{qhd.iq_times}(:,j).*sin(cumsum(2*pi*(v_fm{qhd.iq_times}(:,j))*Ts));
end

% ----- synthesize unvoiced
u_syn_sig = u_am.*sin(cumsum(2*pi*u_fm)*Ts);
% ----- synthesize whole signal
syn_sig = v_syn_sig + u_syn_sig;
% ----- 
qhd.v_am = v_am{qhd.iq_times};
qhd.v_fm = v_fm{qhd.iq_times};
qhd.u_am = u_am;
qhd.u_fm = u_fm;

% uncomment below if resampling is needed
% qhd.v_am = resample(v_am{qhd.iq_times},qhd.Fs,qhd.Fs);
% qhd.v_fm = resample(v_fm{qhd.iq_times},qhd.Fs,qhd.Fs);
% 
% qhd.u_am = resample(u_am,qhd.Fs,qhd.Fs);
% qhd.u_fm = resample(u_fm,qhd.Fs,qhd.Fs);
% qhd.syn_qhd = resample(syn_sig,qhd.Fs,qhd.Fs);
qhd.syn_qhd = syn_sig;
qhd.syn_voiced = v_syn_sig;
qhd.syn_uvoiced = u_syn_sig;

qhd.v_am(qhd.v_am<0) = 0; 
qhd.v_fm(qhd.v_fm<0) = 0; 
qhd.v_fm(qhd.v_fm>qhd.Fs/2) = qhd.Fs; 
end

