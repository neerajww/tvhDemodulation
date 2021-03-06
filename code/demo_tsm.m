


% Code to implement harmonic demodulation, time-scale modification, and synthesis of speech signals.
% For details on the technique, reference paper and contact details of author see:
% link https://github.com/neerajww/tvhDemodulation
% Written by: Neeraj Sharma, CMU, USA
% Last edit: 06/16/2019


% addpath('../legacy_STRAIGHT/src'); % download from https://github.com/HidekiKawahara/legacy_STRAIGHT
sound_path = '../sound/';
store_path = './data/voice_manip/';
store_path_F0 = './data/f0_tracks/';
if (~ isdir(store_path))
    mkdir (store_path);
end

if (~ isdir(store_path_F0))
    mkdir (store_path_F0);
end

fname = {'sub_01_sent_01.wav'};
is_male = 0; % gender of talker
is_track = 1; % F0 track available

% resampling rate
Fs_new = 8e3;

% time scale modification factor (tsm)
alpha = 0.75;

for i = 1:length(fname)
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
    disp(['Loading ' sound_path fname{i}]);
    [x,Fs] = audioread([sound_path fname{i}]);

    % resample Fs to Fs_new
    if Fs ~= Fs_new
        x = resample(x,Fs_new,Fs);
        Fs = Fs_new;
    end

    % make the time vector
    Ts = 1/Fs;
    len = length(x);
    t = 0:Ts:len*Ts-Ts;

    % obtain instantaenous F0 estimates    
    if 0
       % call STRAIGHT 
       [f0s] = exstraightsource(x,Fs);
        % save F0 track
        save([store_path_F0 fname{i}(1:end-4) '_F0_track.mat'],'f0s');
    else
        % load F0 track
        load([store_path_F0 fname{i}(1:end-4) '_F0_track.mat']);
    end
    
    f0s(f0s==0) = 20;    
    len = length(f0s);
    t = t(1:len);
    x = x(1:len);
    f0s = [t' f0s'];
    
    % do qhd analysis
    qhd.filename = fname{i};
    qhd.x = x;
    qhd.nharm = 14; % custom choice
    [sub_sigs,qhd] = tvh_analysis(f0s(:,2),Fs,qhd);

    % do time-stretching
    [sub_sigs_new] = tvh_time_stretch(sub_sigs,qhd,Fs,alpha);

    % do qhd synthesis
    [sub_sigs_new] = tvh_synthesis(sub_sigs_new,qhd,Fs);

    % do save files
    suffix = ['_tsm_alpha_' strrep(num2str(alpha),'.','_')];
    tvh_save_soundfiles(sub_sigs_new,qhd,Fs,store_path,suffix);
end
    
