


% Code to implement harmonic demodulation, speaking style manipulation, and synthesis of speech signals.
% For details on the technique, reference paper and contact details of author see:
% link https://github.com/neerajww/tvhDemodulation
% Written by: Neeraj Sharma, CMU, USA
% Last edit: 06/16/2019


clearvars;
addpath('misc/legacy_STRAIGHT/src'); % downloaded from https://github.com/HidekiKawahara/legacy_STRAIGHT
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
fname = {'6241-61943-0007.wav'};

is_track = 1; % F0 track available

% resampling rate
Fs_new = 16e3;

% time scale modification factor (tsm)
alpha_tsm = 0.75;
alpha_psm = 0.75;
alpha_vibr = 0.75;

for i = 1:length(fname)
    % read wav file
    [x,Fs] = audioread([sound_path fname{i}]);
    disp('Loaded WAV file.');
    % resample Fs to Fs_new
    if Fs ~= Fs_new
        x = resample(x,Fs_new,Fs);
        Fs = Fs_new;
    end
    t = (0:length(x)-1)/Fs;
    % obtain instantaenous F0 estimates    
    if ~is_track
       % call STRAIGHT 
        temp = resample(x,8e3,Fs);
        disp('Extracting F0 track ....');
        [f0] = exstraightsource(temp,8e3);
        disp('Extracted F0 track.');
        t1 = (0:length(f0)-1)/8e3;
        f0 = interp1(t1,f0,t,'linear','extrap');
%         f0 = resample(f0,Fs,8e3);
        f0(f0<25) = 25;
        f0(f0>350) = 350;
        if length(f0)>length(x)
            f0 = f0(1:length(x));
        else
            x = x(1:length(x));
        end
        % save F0 track
        save([store_path_F0 fname{i}(1:end-4) '_F0_track.mat'],'f0');
        audiowrite([store_path_F0 fname{i}(1:end-4) '_F0_track.wav'],f0,Fs);
    else
        % load F0 track
        load([store_path_F0 fname{i}(1:end-4) '_F0_track.mat']);
        f0(f0<25) = 25;
        f0(f0>350) = 350;
        if length(f0)>length(x)
            f0 = f0(1:length(x));
        else
            x = x(1:length(x));
        end
    end
    % init qhd analysis
    qhd.x = x;
    qhd.fname = fname{i}(1:end-4);
    qhd.f0 = f0;
    qhd.Fs = Fs;
    mu_f0 = mean(qhd.f0(qhd.f0>0));
    if mu_f0<150 
        qhd.uBW_am = 1950;
        qhd.uBW_fm = 1950;
        qhd.nu = 0.05;
        qhd.vBW_am = 80;
        qhd.vBW_fm = 80;
        qhd.iq_times = 1;
        qhd.ftimes = 2;
    else
        qhd.uBW_am = 1950;
        qhd.uBW_fm = 1950;
        qhd.nu = 0.1;
        qhd.vBW_am = 100;
        qhd.vBW_fm = 100;
        qhd.iq_times = 1;
        qhd.ftimes = 2;
    end
    qhd.nharm = 14; % custom choice
    
    % do qhd analysis
    [qhd] = tvh_analysis(qhd);

    % do time-stretching
    alpha_tsm = 1.5;
    [qhd] = tvh_time_stretch(qhd,alpha_tsm);
    
    % do time-stretching
    alpha_psm = .85;
    [qhd] = tvh_pitch_scale(qhd,alpha_psm);

    % do vibrato
    vibr_amp = 10;
    vibr_freq = 5;
    [qhd] = tvh_style_manip(qhd,vibr_amp,vibr_freq);

    % do qhd synthesis
    [qhd] = tvh_manip_synthesis(qhd);

    % do save files
    suffix = ['_style_manip_' strrep(num2str(vibr_freq),'.','_')];
    
    % ----- save recons
    sig = qhd.syn_sig;
    sig = sig./max(abs(sig));
    audiowrite([store_path qhd.fname '_recons.wav'],sig,Fs);
    
    % ----- save manip recons
    sig = qhd.new_syn_sig;
    sig = sig./max(abs(sig));
    audiowrite([store_path qhd.fname suffix '.wav'],sig,Fs);

    % ----- save original
    sig = qhd.x;
    sig = sig./max(abs(sig));
    audiowrite([store_path qhd.fname '_orig.wav'],sig,Fs); 
end
    
