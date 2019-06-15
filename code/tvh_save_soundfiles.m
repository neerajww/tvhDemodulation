

function tvh_save_soundfiles(sub_sigs,qhd,Fs,path,suffix)
    
    % ----- save full recons
    sig = sub_sigs.syn_qhd;
    sig = sig./max(abs(sig));
    audiowrite([path qhd.filename(1:end-4) suffix '.wav'],sig,Fs);
    
    % ----- save original
    sig = qhd.x;
    sig = sig./max(abs(sig));
    audiowrite([path qhd.filename(1:end-4) '_orig.wav'],sig,Fs);
end