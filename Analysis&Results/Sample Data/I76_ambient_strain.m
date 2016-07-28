%% I76 - Strain Gauge Data
%
%

%% Load data

% filename
fname = 'TOA5_20Hz_strain_data_3.dat';

% read data skipping 89 rows and 1 col
strain = csvread(fname,89,1);
strain = strain(:,2:end); % index data only

% set labels
dof.labels = {'BF MID G1' ...
              'BF MID G4' ...
              'BF MID G5' ...
              'W MID G4' ...
              'BF 3/4 G4' ...
              'WEB X-GIRDER' ...
              'RIGHT BF'...
              'LEFT BF' ...
              'WEB LOWER' ...
              'WEB UPPER'...
              'CG - TOP' ...
              'CG - BOT'};

%% Time info

fs = 20;
dt = 1/fs;
t = 0:dt:length(strain)*dt-dt;

%% Plot raw data


%% Zero by median
