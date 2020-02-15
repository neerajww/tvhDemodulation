



function [qhd] = tvh_time_stretch(qhd,alpha)


Fs = qhd.Fs;
taxis_1 = (0:size(qhd.v_am,1)-1)*alpha*1/Fs;
taxis_2 = 0:1/Fs:taxis_1(end);

temp_new_v_am = zeros(length(taxis_2),size(qhd.v_am,2));
temp_new_v_fm = temp_new_v_am;

% stretch the voiced segment
for i = 1:qhd.nharm
    temp_new_v_am(:,i) = interp1(taxis_1(:),qhd.v_am(:,i),taxis_2(:));
    temp_new_v_fm(:,i) = interp1(taxis_1(:),qhd.v_fm(:,i),taxis_2(:));
end

% stretch the unvoiced segment
temp_new_u_am = interp1(taxis_1(:),qhd.u_am,taxis_2(:));
temp_new_u_fm = interp1(taxis_1(:),qhd.u_fm,taxis_2(:));

qhd.new_v_am = temp_new_v_am;
qhd.new_v_fm = temp_new_v_fm;

qhd.new_u_am = temp_new_u_am;
qhd.new_u_fm = temp_new_u_fm;

end
