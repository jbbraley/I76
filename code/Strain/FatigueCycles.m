function [C TF_yr] = GetFatigueLife(data,cat)
% Strain Data
data = dat_z{ii}(:,3);
fs = 50; %Hz
% Record length (seconds)
To = size(data,1)/fs;

%% Data rainflow counting
tp = sig2ext(data);
rf = rainflow(tp);

%% Fatigue life calculations
%S-N curve parameters 
switch cat
    case 'A'
        %AASHTO constant to specify curve (ksi^3)
        A = 250e+08;
        % fatigue threshold (ksi)
        Threshold = 24;
    case 'B'
        A = 120e+08;
        Threshold = 16;
    case 'C'
        A = 44e+08;
        Threshold = 10;
end

%% Damage
cycles = rf(3,:); % number of cycles
siga = rf(1,:)*29000*1e-06; % cycle amplitudes (ksi)
N = A./(siga.^3); % Number of cycles to failure at stress level
C = sum(cycles./N); %Cumulative damage fraction (Miner's Rule)

%% Expected time to failure
TF = To/C; % Fatigue life in seconds

TF_yr = TF/3600/24/365; % Fatigue life in years

