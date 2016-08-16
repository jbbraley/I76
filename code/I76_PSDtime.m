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
fname_base = 'I76_07282015_ambient_AM1';
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

%% Sampling Info
% Temporal sampling info

fs = 200;                       % sampling frequnecy [hz]
dt = 1/fs;                      % time step [seconds]
t = 0:dt:length(data)*dt-dt;    % form time vector [seconds]
tMins = t./60;                  % tim vector [minutes]

%% Filter High out High Frequency using Low Pass Filter
forder = 6; % Order of filter function
rip = 0.5; % Pass band ripple
atten_stop = 40; % Stop attenuation in dB
flim = 20; % Frequency pass upper limit
[b,a] = ellip(forder,rip, atten_stop, flim/(fs/2),'low');
% freqz(b,a,32000,fs)

% Apply filter
data_filt = filter(b,a,data);




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

%% Get PSD for time intervals
chan = 13; % Channel of interest


time_step = 20; %Minutes
tstp = time_step*60*fs; %records
nAvg = 300;
percOverlap = 75;

window = floor(length(data)/nAvg);          % window length for nAvg
noverlap = floor(percOverlap/100*window);

[~,~,~,pxx,fc,tc] = spectrogram(data(:,chan),window,noverlap,[],fs);
    %'MinThreshold',-30);
 for ii = 1:floor(size(data,1)/tstp) 
     interval = [(ii-1)*tstp+1 ii*tstp];
     dat = data(interval(1):interval(2),:);
     window = floor(length(dat)/nAvg);          % window length for nAvg
    noverlap = floor(percOverlap/100*window);
    [pxx(:,:,ii) ff(:,:,ii)] = getpsd(dat(:,chan),nAvg,percOverlap,[],fs);
 end
 
 figure
 lh = plot(ff(:,:,1), mag2db(pxx(:,:,1)));
 tvect = time_step:time_step:time_step*size(ff,3);
%  xlim([1 6]);
 ylim([-100 -30])
 for ii = 1:size(pxx,3)
   set(lh,'YData',.8*mag2db(pxx(:,:,ii)));
   drawnow
   pause(1/5)
 end
 
% plot magnitude of poles
pole_ind = [14 19];
figure
plot(tvect,mag2db(permute(pxx(pole_ind,:,:),[3 1 2])))

% Plot center of gravity of psd over time (cross moment of area)
minDB = -120;
for ii = 1:size(pxx,3)
    % Adjust pxx
    pp(:,:,ii) = mag2db(pxx(:,:,ii))-min(mag2db(pxx(1:end-1,:,ii)),[],1);
    % First cross area of moment
    m1(ii) = sum(pp(:,:,ii).*ff(:,:,1))/sum(pp(:,:,ii));
    % Second cross area of moment
     m2(ii) = sum((pp(:,:,ii)).^2.*ff(:,:,1))/sum((pp(:,:,ii)).^2);
end

% [SS, FF, TT, pp] = spectrogram(data(:,chan),window,noverlap, [],fs);
% 
% sf = surf(TT,FF,10*log10(pp));
% sf.EdgeColor = 'none';
% axis tight
% view(0,90)
% 







