
function tvh_save_soundfiles_a0_atten(sub_sigs,sub_f0sigs,qhd,Fs,path,prefix)
    for i = 1:length(qhd.a0_atten)
        sig = sub_f0sigs(i).syn_qhd;
        sig = sig./max(abs(sig));
        audiowrite([path '/' prefix '_a0atten_' num2str(qhd.a0_atten(i)) '_fac_' qhd.filename],sig,Fs);
    end
    
    % ----- save full recons
    sig = sub_sigs.syn_qhd;
    sig = sig./max(abs(sig));
    audiowrite([path '/' prefix '_full_' qhd.filename],sig,Fs);
    
    % ----- save original
    sig = qhd.x;
    sig = sig./max(abs(sig));
    audiowrite([path '/' prefix '_orig_' qhd.filename],sig,Fs);
end