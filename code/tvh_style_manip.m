


function [sub_sigs] = tvh_style_manip(sub_sigs,qhd,Fs,vibr_amp,vibr_freq)

% scale the maginitude of harmonics
taxis = (0:size(sub_sigs.v_am,1)-1)*1/Fs;
for i = 1:qhd.nharm
    sub_sigs.v_fm(:,i) = sub_sigs.v_fm(:,i)+i*vibr_amp*sin(2*pi*vibr_freq*taxis(:));
end
end
