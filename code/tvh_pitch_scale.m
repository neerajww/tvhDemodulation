


function [sub_sigs] = tvh_pitch_scale(sub_sigs,qhd,alpha)

% scale the maginitude of harmonics
for i = 1:qhd.nharm
    sub_sigs.v_fm(:,i) = alpha*sub_sigs.v_fm(:,i);
end

end
