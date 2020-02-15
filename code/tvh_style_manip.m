


function [qhd] = tvh_style_manip(qhd,vibr_amp,vibr_freq)

% scale the maginitude of harmonics
taxis = (0:size(qhd.new_v_am,1)-1)*1/qhd.Fs;
for i = 1:qhd.nharm
    qhd.new_v_fm(:,i) = qhd.new_v_fm(:,i)+i*vibr_amp*sin(2*pi*vibr_freq*taxis(:));
end
end
