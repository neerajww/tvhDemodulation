



function [sub_sigs] = tvh_time_stretch(sub_sigs,qhd,Fs,alpha)



taxis_1 = (0:size(sub_sigs.v_am,1)-1)*alpha*1/Fs;
taxis_2 = 0:1/Fs:taxis_1(end);

temp_new_v_am = zeros(length(taxis_2),size(sub_sigs.v_am,2));
temp_new_v_fm = temp_new_v_am;

% stretch the voiced segment
for i = 1:qhd.nharm
    temp_new_v_am(:,i) = interp1(taxis_1(:),sub_sigs.v_am(:,i),taxis_2(:));
    temp_new_v_fm(:,i) = interp1(taxis_1(:),sub_sigs.v_fm(:,i),taxis_2(:));
end

% stretch the unvoiced segment
temp_new_u_am = interp1(taxis_1(:),sub_sigs.u_am,taxis_2(:));
temp_new_u_fm = interp1(taxis_1(:),sub_sigs.u_fm,taxis_2(:));

sub_sigs.v_am = temp_new_v_am;
sub_sigs.v_fm = temp_new_v_fm;

sub_sigs.u_am = temp_new_u_am;
sub_sigs.u_fm = temp_new_u_fm;

end
