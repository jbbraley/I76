%% I76 Ambient Vibration Monitoring - Data Processing
% 
% John DeVitis
% July 28th, 2016
%
%
% vma fcns called:
%
% * getrms
% * getpsd
% * getcpsd
% * plot_interpmode
% * searchVector
% * normalizeMode


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


%% Load data files
%
% * Record starts at 1:16PM on July 27th, 2016
% * Video began at ~1:45PM
% * File names must be on Matlab's search path

% list of file names (absolute path of where data is stored)
fnames = {'C:\Users\John\Desktop\I76_data\I76_07272016_ambient3.txt';...
          'C:\Users\John\Desktop\I76_data\I76_07272016_ambient3_01.txt';...
          'C:\Users\John\Desktop\I76_data\I76_07272016_ambient3_2.txt';...
          'C:\Users\John\Desktop\I76_data\I76_07272016_ambient3_3.txt'};
      
% pre-allocate data array - empty due to unknown length
data = []; 

% loop files to load
for ii = 1:length(fnames)
    dat = dlmread(fnames{ii});  % load data into temp array, dat
    data = [dat; data];         % concat new file to running list
end

% only keep first 28 channels (channels 29-32 not used)
data = data(:,1:28);


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


%% DOF Coordinates
%
% *Notes:*
% 
% * x - longitudinal, y - transverse, z - vertical
% * z dimension zero point -> centerline of girder
% * dimensions in feet
% * Strand7 model (0,0) starts at first right *interior* girder. These
% coordinates have the (0,0) starting at the first right *exterior* girder.

% grab general dimensions from model
oneSpanLength = 136.5;  
oneSpanWidth = 67.3;   
oneGirderLine = [.25 .5 .75 ]*oneSpanLength;
girderSpacing = 10; 
numberOfGirdersPerSpan = 4;
girderCenterLines(1:4) = (0:numberOfGirdersPerSpan-1)*girderSpacing;
spanTransSpacing = 8; % distance between span 1 and span 2 exterior girders
girderCenterLines(5:8) = girderCenterLines(4) + 8 + girderCenterLines(1:4);

% pre-allocate coordinate array
coords = zeros(size(data,2),3);

% vertical dof - x dimension
coords(1:3,1) = oneGirderLine;
coords(4,1) = oneGirderLine(2);
coords(5:7,1) = oneGirderLine;
coords(8:10,1) = oneGirderLine;
coords(11,1) = oneGirderLine(2);
coords(12:14,1) = oneGirderLine;
coords(15:18,1) = oneSpanLength * 1.25; % dof on second span quarter point

% vertical dof - y dimension
% girder 8 dof
coords([1:3 15],2) = girderCenterLines(8);
% dof 4 - halfway inbetween girders 6 and 7
coords(4,2) = girderSpacing/2 + girderCenterLines(6); 
% girder 5 dof
coords([5:7 16],2) = girderCenterLines(5);
% girder 4 dof
coords([8:10 17],2) = girderCenterLines(4);
% dof 11 - halfway inbetween girders 2 and 3
coords(11,2) = girderSpacing/2 + girderCenterLines(2);
% girder 1 dof
coords([12:14 18],2) = girderCenterLines(1);

% vertical dof - z dimension - leave at zero (from pre-allocation)


% boundary coordinates - x dim
leftBoundary = 1:8;
midBoundary = 9:16;
rightBoundary = 17:24;

bcoords = zeros(size(data,2),3);
bcoords(leftBoundary,1) = 0;
bcoords(midBoundary,1) = oneSpanLength;
bcoords(rightBoundary,1) = oneSpanLength*2;

% boundary coords - y dim
bcoords(leftBoundary,2) = girderCenterLines;
bcoords(midBoundary,2) = girderCenterLines;
bcoords(rightBoundary,2) = girderCenterLines;


% create figure w/ increased resolution (from default)
figWidth = 1120; % pixels
figHeight = 840;
rect = [0 50 figWidth figHeight];
figure('OuterPosition', rect)


% plot vertical dof and boundary nodes to check spatial dof
scatter(coords(:,1),coords(:,2),'o','r','filled');
hold all
scatter(bcoords(:,1),bcoords(:,2),'o','k','filled')
axis equal
hold off
title('Experimental DOF and Boundary Nodes')
xlabel('Longitudinal Dimension - [ft]')
ylabel('Transverse Dimension - [ft]');

% assign to dof structure
dof.coords = coords;
dof.bcoords = bcoords;



%% Data Stats
%
% * Root mean squared (RMS) for each DOF
% * Find min and max RMS
% 

% get rms for each DOF
rmsRaw = getrms(data);
% loop to format
for ii = 1:size(data,2);
    rmsData{ii,1} = dof.labels{ii};
    rmsData{ii,2} = rmsRaw(ii);
end
% display
disp(rmsData);

% get rms stats & display
[Y,I] = min(rmsRaw);
fprintf('\n\nMinimum RMS - ALL - DOF %s - Value %s g\n',num2str(I),num2str(Y));

[Y,I] = max(rmsRaw);
fprintf('Minimum RMS - ALL - DOF %s - Value %s g\n',num2str(I),num2str(Y));

% get max/min for vertical dof
ind = dof.vert.all;
[Y,I] = min(rmsRaw(ind));
fprintf('\n\nMinimum RMS - Vertical - DOF %s - Value %s g\n',num2str(ind(I)),num2str(Y));
[Y,I] = max(rmsRaw(ind));
fprintf('Maximum RMS - Vertical - DOF %s - Value %s[g]\n',num2str(ind(I)),num2str(Y));

% get max/min for transverse dof
ind = dof.trans.sub;
[Y,I] = min(rmsRaw(ind));
fprintf('\n\nMinimum RMS - Transverse - DOF %s - Value %s[g]\n',num2str(ind(I)),num2str(Y));
[Y,I] = max(rmsRaw(ind));
fprintf('Maximum RMS - Transverse - DOF %s - Value %s[g]\n',num2str(ind(I)),num2str(Y));

% get max/min for vertical dof
ind = dof.long.all;
[Y,I] = min(rmsRaw(ind));
fprintf('\n\nMinimum RMS - Longitudinal - DOF %s - Value %s[g]\n',num2str(ind(I)),num2str(Y));
[Y,I] = max(rmsRaw(ind));
fprintf('Maximum RMS - Longitudinal - DOF %s - Value %s[g]\n',num2str(ind(I)),num2str(Y));


%% Time Plots - Vertical DOF
%
% 

% create figure w/ increased resolution (from default)
figWidth = 1120; % pixels
figHeight = 840;
rect = [0 50 figWidth figHeight];
figure('OuterPosition', rect)

% plot vertical superstructure
ind = dof.vert.super;
plot(tMins,data(:,ind));
title('Vertical DOF - Superstructure');
xlabel('Time [seconds]')
ylabel('Acceleration [g]')
ylim([-1 1])
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow

% plot vertical sub
ind = dof.vert.sub;
plot(tMins,data(:,ind));
title('Vertical DOF - Pier Cap');
xlabel('Time [minutes]')
ylabel('Acceleration [g]')
ylim([-1 1])
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


%% Time Plots - Transverse DOF 
%
% 

% plot vertical superstructure
ind = dof.trans.sub;
plot(tMins,data(:,ind));
title('Transverse DOF');
xlabel('Time [seconds]')
ylabel('Acceleration [g]')
ylim([-1 1])
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


%% Time Plots - Longitudinal DOF 
%
% 

% plot vertical superstructure
ind = dof.long.super;
plot(tMins,data(:,ind));
title('Longitudinal DOF - Superstructure');
xlabel('Time [seconds]')
ylabel('Acceleration [g]')
ylim([-1 1])
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow

% plot vertical superstructure
ind = dof.long.sub;
plot(tMins,data(:,ind));
title('Longitudinal DOF - Substructure');
xlabel('Time [seconds]')
ylabel('Acceleration [g]')
ylim([-1 1])
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


%% Power Spectral Density (PSD) - Plot All
%
% Notes:
%
% * Data record broken into 50 segments for averaging
% * 75 percent overlap of each segment
% * Default nfft
%

nAvg = 50;  % number of averages
perc = 75;  % percent overlap
nfft = [];  % use default nfft lines

% get psd
[pxx,f] = getpsd(data,nAvg,perc,nfft,fs);

% display frequency resolution
fprintf('Observable frequency range: 0-%s[Hz]\n',num2str(f(end)));
fprintf('Frequency resolution: %s[Hz]\n',num2str(f(2)));


ind = 1:size(data,2);
plot(f,mag2db(pxx(:,ind)))
title('PSD - All DOF');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


%% PSD - Plot Vertical
%
%

% full freq plot
ind = dof.vert.super;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Vertical - Superstructure');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow

% zoom to narrow freq bandwidth
bnds = [1.5 5]; % freq bnds
ind = dof.vert.super;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Vertical - Superstructure - Zoom');
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
snapnow


% PIER CAP - full freq plot
ind = dof.vert.sub;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Vertical - Pier Cap');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


% PIER CAP - zoom to narrow freq bandwidth
bnds = [1.5 10]; % freq bnds
ind = dof.vert.sub;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Vertical - Pier Cap - Zoom');
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
snapnow


%% PSD - Plot Transverse
%
%

% full freq plot
ind = dof.trans.sub;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Transverse');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


%% PSD - Plot Longitudinal
%
%

% full freq plot
ind = dof.long.super;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Longitudinal - Pier Cap');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow


% full freq plot
ind = dof.long.sub;
plot(f,mag2db(pxx(:,ind)))
title('PSD - Longitudinal - Piers');
xlabel('Frequency [Hz]')
ylabel('Power [dB]')
grid minor
legend(dof.labels(ind))
ah = gca;
ah.FontName = 'Times';
ah.FontSize = 18;
snapnow



%% Cross-Power Spectral Density (CPSD) - Vertical - Superstructure ONLY
%
% Get CPSD for phase information and mode shape plotting
%
% *Notes:*
%
% * Reference: DOF 
% * Number of Averages: Data record broken into 50 segments for averaging
% * Percent Overlap: 75 percent overlap of each segment
% * NFFT: Default nfft
%

refInd = 3; % reference dof index
nAvg = 50;  % number of averages
perc = 75;  % percent overlap
nfft = [];  % use default nfft lines

% get cpsd
[pxy,f] = getcpsd(data,refInd,nAvg,perc,nfft,fs);

% display frequency resolution
fprintf('\n\nObservable frequency range: 0-%s[Hz]\n',num2str(f(end)));
fprintf('Frequency resolution: %s[Hz]\n',num2str(f(2)));


% create figure w/ increased resolution (from default)
figWidth = 1120; % pixels
figHeight = 840;
rect = [0 50 figWidth figHeight];
figure('OuterPosition', rect)

% real
bnds = [1.5 5]; % freq bnds
ind = dof.vert.super;
plot(f,real(pxy(:,ind)))
title(['CPSD - Vertical - Superstructure - Real - Reference: ' num2str(refInd)]);
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
snapnow


% imaginary
bnds = [1.5 5]; % freq bnds
ind = dof.vert.super;
plot(f,imag(pxy(:,ind)))
title('CPSD - Vertical - Superstructure - Imaginary');
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
snapnow


%% Pseudo Impulse Response Function (PIRF) and pH
%
%
%

ind = dof.vert.super;
[pH,ff,pirf,tt] = getpH(data(:,ind),ind,fs,[]);

% plot pirf
ref = 1;
ind = dof.vert.super;

figure;
plot(tt,pirf{ref}(:,ind));


% grab usable time info (first 60 seconds)
tend = find(t>60,1,'first');

% pull out usable time window for each ref in pirf
for ii = 1:length(pirf)
    pirf{ii} = pirf{ii}(1:tend,:);
end

% get fft of new time window
nfft = 2^nextpow2(size(pirf{1},1));
ff = fs*(0:nfft/2)/nfft; % form freq vector 

% loop refs and perform fft
for ii = 1:length(pirf)
    % fft of pirf for pseudoFRF of usable portion
    pH{ii} = fft(pirf{ii},nfft);
    % reduce to one-sided
    pH{ii} = pH{ii}(1:(nfft/2)+1,:);
end

% plot usable time window
figure
plot(tt(1:length(pirf{ref})),pirf{ref})


% plot pH
ref = 1;
ind = dof.vert.super;
figure
ah = axes;
plot(ff,mag2db(abs(pH{ref}(:,ind))))
xlim([1 10])
grid minor
title(['Pseudo Frequency Response Function - REF ' num2str(ref)]);
xlabel('Frequency [Hz]');
ylabel('[db]');
ah.FontName = 'Times';
ah.FontSize = 18;
legend(dof.labels(ind))
lh = get(ah,'children');
set(lh,'linewidth',1);


% loop refs to window new time record
perc = 25; % percent final amplitude
for ii = 1:length(pirf)
    [outwin,rwin] = accelWin(pirf{ii},fs,perc);
    pirf_win{ii} = outwin;
end

% loop references and perform fft
for ii = 1:length(pirf_win)
    % fft of pirf for pseudoFRF
    pH_win{ii} = fft(pirf_win{ii},nfft);
    % reduce to one-sided
    pH_win{ii} = pH_win{ii}(1:(nfft/2)+1,:);
end

% plot window
figure
ah = axes;
plot(t(1:tend),rwin)


% plot pH
ref = 1;
ind = dof.vert.super;
figure
ah = axes;
plot(ff,mag2db(abs(pH_win{ref}(:,ind))))
xlim([1 10])
grid minor
title(['Pseudo Frequency Response Function - REF ' num2str(ref)]);
xlabel('Frequency [Hz]');
ylabel('[db]');
ah.FontName = 'Times';
ah.FontSize = 18;
legend(dof.labels(ind))
lh = get(ah,'children');
set(lh,'linewidth',1);




%% CMIF

% for frf w/ correct indices
ns = length(ff);
no = length(dof.vert.super);
ni = no;
H = zeros(ns,no*ni);
hInd = 1:no*ni;
hInd = reshape(hInd,no,ni);
for ii = 1:length(pH_win)
    H(:,hInd(:,ii)) = pH_win{ii};
end

% convert to 3d format
HH = frf_two2three(H,no,ni);

% plot imag cmif
[uu,ss,vv] = cmif_svd(imag(HH));
fh = figure;
ah = axes;
bnds = [1 10];
ah = cmif_plot(ah,f,ss,bnds,0,0);



%% Mode Shape Plots - Vertical DOF - Superstructure ONLY
%
%

% % get frequency index (from cpsd)
% peakFreqs = [2.106 2.148 2.435 2.533 3.204 3.345 3.448 3.503 3.558];
% [~,peakInd] = searchVector(f,peakFreqs);


% get frequency index (from pH/pirf)
peakFreqs = [1.965 2.039 2.075 2.173 2.417 2.502 2.563 2.808 3.174 3.223...
    3.54 3.577 3.613];
[~,peakInd] = searchVector(ff,peakFreqs);

% choose rank
rank = ones(size(peakInd));


% % create figure w/ increased resolution (from default)
% figWidth = 1120; % pixels
% figHeight = 840;
% rect = [0 50 figWidth figHeight];
% figure('OuterPosition', rect)
figure
ah = axes;
for ii = 1:length(peakInd)
    mode = ii;
    scale = 25;
    xres = 50;
    yres = 25;

    U = normalizeMode(uu(:,1,peakInd(mode)));

    fh = figure;
    ah = axes;
    plot_interpmode(ah,dof.coords(dof.vert.super,:),dof.bcoords,U,xres,yres,scale);
    title(ah,['Frequency: ' num2str(ff(peakInd(mode))) ' Hz'])
end



% single span plot

span1 = [1 2 3 4 5 6 7 15 16];
span2 = [8:14 17 18];

span1bcoords = find(bcoords(:,2)>33,100);
span2bcoords = find(bcoords(:,2)<33,100);


pname = 'C:\Users\John\Desktop\I76\code\ModeShapePlots';
mkdir(pname);


for ii = 1:length(peakInd)
    mode = ii;
    scale = 25;
    
    xres = 30;
    yres = 15;

    U = normalizeMode(uu(:,1,peakInd(mode)));

    fh = figure;
    ah = axes;
    
    % span1
    
    plot_interpmode(ah,dof.coords(dof.vert.super(span1),:),...
        dof.bcoords(span1bcoords,:),U(span1),xres,yres,scale);
    hold on
    plot_interpmode(ah,dof.coords(dof.vert.super(span2),:),...
        dof.bcoords(span2bcoords,:),U(span2),xres,yres,scale);
    title(ah,['Frequency: ' num2str(ff(peakInd(mode))) ' Hz'])
    hold off
    
    fname = ['Mode ' num2str(mode) '.png'];
    sname = fullfile(pname,fname);
        
    % clean up
    print(fh,sname,'-dpng','-r0')  % save
    cla(ah);                       % clear axes
    fprintf('Done. \n')            % update user
        
end



















