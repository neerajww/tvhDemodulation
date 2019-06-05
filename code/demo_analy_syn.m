

% when do we perceive two voices during simultaneous playback of two
% same utterances
% - this will help to address grouping of features in voices.
% This code does the following:
% a. Takes a speech utterance
% b. Synthesizes 10 samples each with:
%   1. 5 semitone shifts up
%   2. 5 semitone shifts down
%   3. 5 steps of f0 accentuation
%   4. 2 steps of onset shifts with all the above

addpath('/Users/neeks/Desktop/Documents/work/code/matlab_codes/others_codes/legacy_STRAIGHT/src');
sound_path = '../sound/';
store_path = './data/a0timbre/';
if (~ isdir(store_path))
    mkdir (store_path);
end

spkr_ids = {'M_2','F_4'};
nos_sent = 1;

Fs_new = 8e3;

for i = 1:length(spkr_ids)
    fnames = dir([sound_path 'starkey_' spkr_ids{i} '-*.wav']);
    nfiles = length(fnames);
    rindx = randsample(1:nfiles,nos_sent);
    
    for j = 1:nos_sent

        filename = fnames(rindx(j)).name;
        display(filename);
       
        % init qhd params
        if i == 1
            qhd.uBW_am = 1950;
            qhd.uBW_fm = 1950;
            qhd.nu = 0.05;
            qhd.vBW_am = 60;
            qhd.vBW_fm = 60;
            qhd.iq_times = 2;
            qhd.ftimes = 2;
        else
            qhd.uBW_am = 1950;
            qhd.uBW_fm = 1950;
            qhd.nu = 0.1;
            qhd.vBW_am = 100;
            qhd.vBW_fm = 100;
            qhd.iq_times = 2;
            qhd.ftimes = 2;
        end
        
        % read wav file
        [x,Fs] = audioread([sound_path filename]);
        
        % match Fs to Fs_new
        if Fs ~= Fs_new
        x = resample(x,Fs_new,Fs);
        Fs = Fs_new;
        end
        
        Ts = 1/Fs;
        len = length(x);
        t = 0:Ts:len*Ts-Ts;

        % call STRAIGHT for f0 estimates
        if 1
%         [f0s] = MulticueF0v14(x,Fs);
        [f0s,ap] = exstraightsource(x,Fs);
        f0s(f0s==0) = 20;    
        len = length(f0s);
        t = t(1:len);
        x = x(1:len);
        f0s = [t' f0s'];
        end
        
        % do qhd
        qhd.filename = filename;
        qhd.x = x;
        qhd.nharm = 14;
        [sub_sigs,qhd] = tvh_analysis(f0s(:,2),Fs,qhd);

        % a0 attenuate
        qhd.a0_atten = [-1 .1 .25 .5 1];
        [sub_a0atten] = tvh_a0_atten(sub_sigs,qhd,Fs);
        
        prefix = 'T0_A0_atten';
        tvh_save_soundfiles_a0_atten(sub_sigs,sub_a0atten,qhd,Fs,store_path,prefix);        
        %return;       
        
    end
end
