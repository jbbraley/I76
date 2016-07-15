

uID = 1;
pname = 'C:\Users\John\Projects_Git\I76\Analysis&Results\Prelim Analysis\DOF Sensitivity\';
cd(pname)
addpath(genpath('C:\Users\John\Projects_Git\ramps'));
addpath(genpath('C:\Users\John\Projects_Git\vma'));
NID_fname = 'NodeID1.csv';
BNID_fname = 'BoundNodes.csv';
model_name = '2-span_APriori_wPiers';
result_name = '2-span_APriori_wPiers';
nmodes = 10;

% Load nodes of interest
NodeID = dlmread([pname NID_fname], '\n');
% Load Boundary Nodes
BNodes = dlmread([pname BNID_fname], '\n');
%% Initialize St7 API library
InitializeSt7();

%% Open model file
ScratchPath = 'C:/Temp';
St7OpenModelFile(uID, pname, model_name, ScratchPath);

%% Get undeformed node coordinates
Coords = getNodeLoc(uID, NodeID');
Bcoords =  getNodeLoc(uID, BNodes');
    
%% Pull Node Results
FilePath = [pname result_name];
NodeRes = Get_NFARes(uID, FilePath, NodeID', nmodes);

%% Close Model Files
St7CloseModelFile(uID)

%%Plot underformed shape
ah = figure;
modeInterpSparse(Coords(:,1), Coords(:,2), NodeRes(:,mode,3), Bcoords(:,1), Bcoords(:,2), zeros(size(Bcoords,1),1), 100);
scale = 20000;
mode = 10;
figure
scatter3(Coords(:,1), Coords(:,2), Coords(:,3))
hold all
scatter3(Coords(:,1)+NodeRes(:,mode,1)*scale, Coords(:,2)+NodeRes(:,mode,2)*scale, Coords(:,3)+NodeRes(:,mode,3)*scale)
