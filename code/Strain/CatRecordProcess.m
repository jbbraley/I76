%% 24 hr record examination
load('C:\Users\John\Documents\RutgersResearch\Virtual Lab\I76\data\PostProcessed\dat_z.mat')

dat_all = [];

for ii = 1:length(dat_z)
    dat_all = cat(1,dat_all,dat_z{ii}(:,2:13));
    rec_l(ii) = size(dat_z{ii},1);
end

%% Plot data
% set labels
dof.labels = {'BF MID G1' ...
              'BF MID G4' ...
              'BF MID G5' ...
              'WEB MID G4' ...
              'BF 3/4 G4' ...
              'WEB XG' ...
              'RIGHT BF'...
              'LEFT BF' ...
              'WEB LOWER' ...
              'WEB UPPER'...
              'XG MID TOP' ...
              'XG MID BOT'};

%% Remove data points

%Calculate fatigue life for positive moment dof
hz20_ind = 7:13;
dat_fs = ones(1,length(dat_z))*50;
dat_fs(hz20_ind) = 20*ones(1,length(hz20_ind));
dof_ind = [1:3 5];
% record length in seconds
rec_delt = sum(rec_l./dat_fs);

n=1;
cat = {'A'; 'B'; 'C'};
for ii = dof_ind
    for jj = 1:3        
        [C(jj,n), TF_yr(jj,n)] = GetFatigueLife(dat_all(:,ii),'Strain',[],rec_delt,cat{jj});
    end
    n=n+1;
end

% Calculate fatigue life for negative moment and box girder (bottom)
dof_ind2 = [7 8 12];
records = [1:7 10:16];
rec_length = sum(rec_l(records)./dat_fs(records));

end_ind = [sum(rec_l(1:7)) sum(rec_l(1:9)+1)];

for ii = dof_ind2
    for jj = 1:3        
        [C(jj,n), TF_yr(jj,n)] = GetFatigueLife(dat_all([1:end_ind(1) end_ind(2):end],ii),'Strain',[],rec_length,cat{jj});
    end
    n=n+1;
end

%% Write fatigue life results to file
fname = 'FatigueLife_yrs.txt';
Header = dof.labels([dof_ind dof_ind2]);
fid = fopen(fname,'w');
formatSpec = '%s\t%s\t%s\t%s\t%s\t%s\t%s\n';
fprintf(fid,formatSpec,Header{:})
fclose(fid)
dlmwrite(fname,TF_yr,'-append','delimiter','\t');

%% fft adn filter
fs = 50;
dat1 = dat_all(1:sum(rec_l(1:6)),:);
nAvg = 80;
percOverlap = 70;
nfft = []; % use default nfft lines

% Compute and plot PSD
figure
[pxx,f] = getpsd(dat1,nAvg,percOverlap,nfft,fs);
plot(f,mag2db(pxx(:,dof_ind)))
title('Power Spectral Density of Strain Data')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
legend(dof.labels(dof_ind))
    
% Apply bandstop filter   
[b,a] = butter(5, [1 24]/(fs/2), 'stop');
y = filter(b,a,dat1);
   
%Compute and plot PSD of filtered data    
[pxx2,f2] = getpsd(y,nAvg,percOverlap,nfft,fs);
figure
plot(f2,mag2db(pxx2(:,dof_ind)))
title('Power Spectral Density of Filtered Strain Data')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
legend(dof.labels(dof_ind))

% plot comparison of filtered and unfiltered data
record_ind = [2.202e+05 2.213e+05];
figure
tv = 0:1/fs:(record_ind(2)-record_ind(1))/fs;
plot(tv, dat1(record_ind(1):record_ind(2),2));
hold all
plot(tv,y(record_ind(1):record_ind(2),2));
title('Filtered Time History');
xlabel('Time (sec)');
ylabel('Strain (x10^6)');
legend({'Raw Data', 'Filtered Data'});
xlim([0 22]);

% Plot Girder 5 strain (filtered and raw)
TV = 0:1/fs:(size(dat1,1)-1)/fs;
figure
plot(TV,dat1(:,3))
hold all
plot(TV,y(:,3))
legend({'Raw', 'Filtered'})
ylabel('Strain (x10^6)')
title('Dynamic Amplification of Strain')

% Plot girders filtered
figure
plot(TV,y(:,dof_ind));
legend(dof.labels(dof_ind))
xlabel('Time (sec)');
ylabel('Strain (x10^6)')
title('Typical Strain Response (Filtered)')

