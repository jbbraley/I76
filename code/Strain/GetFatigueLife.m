function [C, TF_yr] = GetFatigueLife(data,type,fs,To,cat)
%%GETFATIGUELIFE calculates cumulative dmage fraction and estimated total
%%fatigue life

% Input
%   data - 1xN vector. time history of strain or stress
%   type - String. 'Stress' or 'Strain' - microstrain
%   fs - DBL. Sampling Frequency (Hz)
%   To - Record length in seconds
%   cat - String. 'A', 'B' or 'C': Fatigue Detail Category

% Output
%   C - DBL. Cumulative Damage Fraction. (0: no damage accumulated, 1:
%   failure)
%   TF_yr - DBL. Fatigue life in years.

%       --John Braley 2016

if isempty(To)
    %% Record length (seconds)
    To = size(data,1)/fs;
end
%% Data rainflow counting
tp = sig2ext(data);
rf = rainflow(tp);

%% S-N curve parameters 
switch cat
    case 'A'
        %AASHTO constant to specify curve (ksi^3)
        A = 250e+08;
        % fatigue threshold (ksi) (not currently utilized)
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
switch type
    case {'Strain' 'strain'}
        siga = rf(1,:)*29000*1e-06; % cycle amplitudes (ksi)
    case {'Stress' 'stress'}
        siga = rf(1,:);
end
N = A./(siga.^3); % Number of cycles to failure at stress level
C = sum(cycles./N); %Cumulative damage fraction (Miner's Rule)

%% Expected time to failure
TF = To/C; % Fatigue life in seconds
TF_yr = TF/3600/24/365; % Fatigue life in years

