%% I76 - Strain Gauge Data
%
%
% Meta:
%
% 1. Girder 1 Bottom Flange at Midspan
% 2. Girder 4 Bottom flange midspan
% 3. Girder 5 bottom flange midspan
% 4. Girder 4 web (12" above BF) midspan
% 5. Box 4 bottom flange at 3/4 span (35' from CL of pier 7)
% 6. Cross Girder (middle) on north web at 12" above bottom flange
% 7. Girder 4 right bottom flange at 2' north of Pier 7 CL
% 8. Girder 4 left bottom flange at 2' north of Pier 7 CL
% 9. Girder 4 web X" above flange at 2' north of Pier 7
% 10. Girder 4 web X" above flange at 2' north of Pier 7
% 11. Box Girder top flange at 12" off north flange edge
% 12. Box Girder bottom flange at 12" off south flange edge

%% Load data

% filename
fname = 'TOA5_20Hz_strain_data_3.dat';

% read data skipping 89 rows and col's 1 and 2
strainRaw = csvread(fname,89,2);


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

% index channels
ind = 1:length(dof.labels);  
strainRaw = strainRaw(:,ind);


%% Time info

fs = 50;
dt = 1/fs;
t = 0:dt:length(strainRaw)*dt-dt;


%% Zero by mean

% med = median(strainRaw); % median
med = mean(strainRaw); % mean
strain = zeros(size(strainRaw));
for ii = 1:size(strainRaw,2)
    strain(:,ii) = strainRaw(:,ii) - med(ii);
end



%% Plot raw data
figure
plot(t,strainRaw)
legend(dof.labels)



%% Plot zero'd strain
figure
x = t/60;
plot(x,strain)
xlabel('Time [min]')
ylabel('\mu\epsilon')
set(gca,'FontSize',12)
grid(gca,'minor')
legend(dof.labels,'location','northwest')
ylim([-175 175])
lh = get(gca,'children');
set(lh,'linewidth',1.5)
xlim([x(1) x(end)])


%% FFT of signals (scaled)

% data to process
data = strain;

% freq info
nfft = size(data,1);      % no. spectral lines (double sided)
ns = nfft/2;                % no. spectral lines (single side)
fn = fs/2;                  % nyquist freq
f = fn*linspace(0,1,ns);    % single sided frequency vector [hz]
ff = fn*linspace(-1,1,ns*2); % double sided frequnecy vector [hz]

% get fft
yy = fft(data,nfft);

% get single sided and scale mag
yy = abs(yy/nfft);                  % scale two sided
yy = yy(1:ns,:);                    % concat positive freq
yy(2:end-1,:) = 2*yy(2:end-1,:);    % double amplitude for signle side
strainfft = yy;                     % save 


%% FFT Plot - Log Mag
figure
plot(f,mag2db(abs(strainfft)))





%% CPSD
data = strain;

refInd = 5; % reference dof index
nAvg = 50;  % number of averages
perc = 75;  % percent overlap
nfft = [];  % use default nfft lines

% get cpsd
[pxy,fxy] = getcpsd(data,refInd,nAvg,perc,nfft,fs);

% display frequency resolution
fprintf('\n\nObservable frequency range: 0-%s[Hz]\n',num2str(f(end)));
fprintf('Frequency resolution: %s[Hz]\n',num2str(f(2)));

% real
bnds = [1.5 5]; % freq bnds
ind = 1:12;
plot(fxy,real(pxy(:,ind)),'.-')
title(['CPSD - Strain - Real - Reference: ' dof.labels(refInd)]);
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
xlim(bnds) 
grid minor
legend(dof.labels(ind))
lh = get(gca,'children');   % find line handles of current axes
set(lh,'linewidth',1);      % set linewidth 
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
ylim([-10 35])
snapnow



%% PSD 
data = strain;

nAvg = 8;  % number of averages
perc = 50;  % percent overlap
nfft = [];  % use default nfft lines

% get psd
[pxx,fxx] = getpsd(data,nAvg,perc,nfft,fs);

% display frequency resolution
fprintf('Observable frequency range: 0-%s[Hz]\n',num2str(f(end)));
fprintf('Frequency resolution: %s[Hz]\n',num2str(f(2)));

% all
ind = 1:size(data,2);
plot(fxx,mag2db(pxx(:,ind)),'.-')
title('PSD - All DOF');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
lh = get(gca,'children');
set(lh,'linewidth',2)
xlim([0 25])
snapnow

% zoom
ind = 1:size(data,2);
plot(fxx,mag2db(pxx(:,ind)),'.-')
title('PSD - All DOF');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
xlim([1.5 5])
ylim([-60 50])
lh = get(gca,'children');
set(lh,'linewidth',1)
snapnow



%% time window event & get fft
[~,win] = searchVector(t/60,[18 18.7]);

% FFT of signals (scaled)

% data to process
data = strain(win(1):win(2),:);

% freq info
nfft = size(data,1);      % no. spectral lines (double sided)
ns = nfft/2;                % no. spectral lines (single side)
fn = fs/2;                  % nyquist freq
f = fn*linspace(0,1,ns);    % single sided frequency vector [hz]
ff = fn*linspace(-1,1,ns*2); % double sided frequnecy vector [hz]

% get fft
yy = fft(data,nfft);

% get single sided and scale mag
yy = abs(yy/nfft);                  % scale two sided
yy = yy(1:ns,:);                    % concat positive freq
yy(2:end-1,:) = 2*yy(2:end-1,:);    % double amplitude for signle side
strainfft = yy;                     % save 


%% FFT Plot - Log Mag
figure
plot(f,mag2db(abs(strainfft)))



