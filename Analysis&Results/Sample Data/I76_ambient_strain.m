%% I76 - Strain Gauge Data
%
%

%% Load data

% filename
fname = 'TOA5_20Hz_strain_data_3.dat';

% read data skipping 89 rows and col's 1 and 2
strainRaw = csvread(fname,89,2);


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

% index channels
ind = 1:length(dof.labels);  
strainRaw = strainRaw(:,ind);


%% Time info

fs = 20;
dt = 1/fs;
t = 0:dt:length(strainRaw)*dt-dt;


%% Zero by median
med = median(strainRaw);
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
plot(t/60,strain)
xlabel('Time [min]')
ylabel('\mu\epsilon')
set(gca,'FontSize',18)
grid(gca,'minor')
legend(dof.labels)
ylim([-175 175])














