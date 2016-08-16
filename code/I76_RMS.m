%% I76 Ambient Vibration Monitoring - Data Processing
% 
% John Braley
% August 15th, 2016
%
%
% vma fcns called:
%
% * getrms



%% Superstructure Instrumentation Plan
%
% *Note* the DOF call outs - they are also the channel numbers (column
% indices of the data array)
% 
% <<instrumentation_superstructure.png>>
%


%% Substructure Instrumentation
%
% *Pier G6:*
%
% <<instrumentation_pierG6.png>>
%
%
%
% *Pier G7:*
%
% <<instrumentation_pierG7.png>>
%

%% Import multiple data files
pname = 'F:\I76\07282016_Data';      
fname_base = 'I76_07282015_ambient_AM2';
base_char = length(fname_base);
fnames = dir(pname);

order = [];
dat = [];
n=1;
for ii = 1:size(fnames,1)
    if length(fnames(ii).name)>base_char && strcmp(fnames(ii).name(1:base_char),fname_base)
        try
            dat{n} = dlmread([pname '\' fnames(ii).name],'\t');
        catch
            continue
        end
%         Big(n,:) = max(dat,[],1)-mean(dat,1);
%         Smal(n,:) = min(dat,[],1)-mean(dat,1);
        
        rec = str2double(fnames(ii).name(base_char+2:end-4));
        if isnan(rec)
            order(n) = 0;
        else
            order(n) = rec;
        end
        n=n+1;
    end
end

% Sort
[~, rec_ind] = sort(order);
dat = dat(rec_ind);

% Concat
data = [];
for ii = 1:length(dat)
    data = cat(1,data,dat{ii});
end
      
clear dat

% only keep first 28 channels (channels 29-32 not used)
data = data(:,1:28);

%% Filter High out High Frequency using Low Pass Filter
forder = 6; % Order of filter function
rip = 0.5; % Pass band ripple
atten_stop = 40; % Stop attenuation in dB
flim = 20; % Frequency pass upper limit
[b,a] = ellip(forder,rip, atten_stop, flim/(fs/2),'low');
% freqz(b,a,32000,fs)

% Apply filter
data_filt = filter(b,a,data);

%% Sampling Info
% Temporal sampling info

fs = 200;                       % sampling frequnecy [hz]
dt = 1/fs;                      % time step [seconds]
t = 0:dt:length(data)*dt-dt;    % form time vector [seconds]
tMins = t./60;                  % tim vector [minutes]


%% DOF Indicies & Labels
%
% Indices for vertical, transverse, and longitudinal DOF with corresponding
% DOF labels
%
% *Notes:*
%
% * Indices are the respective column index for referencing the data matrix
% 

% vertical dof indices
dof.vert.super = 1:18;
dof.vert.sub   = [22 28];
dof.vert.all = [dof.vert.super dof.vert.sub];

% transverse dof indices
dof.trans.sub = [19 24 27];

% longitudinal dof indices
dof.long.super = [20 21 23];
dof.long.sub = [25 26];
dof.long.all = [dof.long.super dof.long.sub];

% index for all dof
dof.all = 1:size(data,2);

% build dof legend
leg = cell(1,length(dof.all));
for ii = 1:length(leg)
    leg{ii} = ['DOF: ' num2str(ii)];
end
dof.labels = leg; % assign to dof struct

%% Get RMS for time intervals
period = 20; %record interval length (minutes)
div = floor(length(data_filt)/(period*60*fs)); % Number of periods in data record
% Loop through to get RMS for each period
DataRMS = [];
for ii = 1:div
    dat_inter = [(ii-1)*(period*60*fs)+1 ii*(period*60*fs)];
    DataRMS(ii,:) = getrms(data_filt(dat_inter(1):dat_inter(2),:));
end
% Create time vector (For plotting)
t_p = period:period:div*period;

figure
plot(t_p,DataRMS(:,[2 4 6 9 11 13]));

save([fname_base '_RMS'],'DataRMS');


%% Import all RMS files
rmsnames = dir('*RMS.mat');
clear DataRMS
RMS = [];
FM = [];
file_mark = 0;
for ii = 1:length(rmsnames)
    load(rmsnames(ii).name);
    RMS = cat(1,RMS,DataRMS);
    fm = zeros(size(DataRMS,1),1)+file_mark;
    FM = cat(1,FM,fm);
    file_mark = abs(file_mark-1);
    clear DataRMS
end

save('FullRMS','RMS')

load('FullRMS');
tv = period:period:size(RMS,1)*period;
figure
plot(tv,RMS);











