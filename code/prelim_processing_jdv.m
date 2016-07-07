%% I76 prelim processing
%
% vma fcns called:
%   getrms
%   getpsd
% 
% jdv 07072016


% file info
fname = 'C:\Users\John\Desktop\I76 Data\ambient1.txt';

% load data
data = dlmread(fname);

% channel labels/names
chanLabels = {'Pier 2 - W. Longitudinal';...
              'Pier 2 - Middle Vertical';
              'Pier 2 - E. Longitudinal';
              'Pier 2 - Transverse';...
              'Pier 3 - W. Longitudinal';...
              'Pier 3 - Middle Vertical';...
              'Pier 3 - E. Longitudinal';...
              'Pier 3 - Transverse';...
              'Pier 5 - W. Longitudinal';...
              'Pier 5 - Middle Vertical';...
              'Pier 5 - E. Longitudinal';...
              'Pier 5 - Transverse';...
              'Pier 7 - W. Longitudinal';...
              'Pier 7 - Middle Vertical';...
              'Pier 7 - East Longitudinal';...
              'Pier 7 - Transverse'};
 
% sampling info
fs = 200;
dt = 1/fs;
t = 0:dt:length(data)*dt-dt;

%% time plots

% plot all
figure
plot(t,data);
legend(chanLabels);

% subplots
subplot(1,1,4)
plot(t,


%% psd
nAvg = 50;
percOverlap = 75;
nfft = []; % use default nfft lines

% get psd
[pxx,f] = getpsd(data,nAvg,percOverlap,nfft,fs);
% figure
plot(f,mag2db(pxx))
legend(chanLabels);


%% rms stats
rms_dat = getrms(data);

% loop to store
cnt = 0;
for ii = 1:4
    for jj = 1:4
        cnt = cnt+1;
        rms_info{cnt,1} = [ chanLabels{cnt} ' - RMS: ' num2str(rms_dat(cnt)) ];
    end
end

% get rms stats
[Y,I] = min(rms_dat);
rmsStats.minVal = Y;
rmsStats.minName = chanLabels{I};

[Y,I] = max(rms_dat);
rmsStats.maxVal = Y;
rmsStats.maxName = chanLabels{I};











