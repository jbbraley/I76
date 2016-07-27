function I76_Ambient_PostProcessing(data,dof)
%% I76 Ambient Vibration Monitoring - Post-Processing
% 
% John DeVitis
% July 28th, 2016
%
% vma fcns called:
% *getcpsd

%% Superstructure Instrumentation Plan
%
% *Note* the DOF call outs - they are also the channel numbers (column
% indices of the data array)
% 
% <<instrumentation_superstructure.png>>
%
