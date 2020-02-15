


function [qhd] = tvh_pitch_scale(qhd,alpha)

% scale the maginitude of harmonics
for i = 1:qhd.nharm
    qhd.new_v_fm(:,i) = alpha*qhd.new_v_fm(:,i);
end

end
