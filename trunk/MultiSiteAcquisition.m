% This script is an example of how to run Throopi the Roboscope. 
%
% "Algorithm" outline
% =========================
% 1. Initialize the scope, slide and image database 
% 2. get 
%     3.1 Initialize a acqusition data secquence that contains the
%           position, exposures etc for all the sites within this well.
%     3.2 Initialize an acquisition sequence based on the AcqData object
%           from 3.1
%     3.3 starts and waits for the dequence to end. 
% 

%% Init Scope

% the scope configuration file that will be passed to MicroManager
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

%%  Create the structures needed for acquisitions

% not sure what will get here. 
MiscData.ProjectName='InitialTest';
MiscData.DatasetName='Tst1';
MiscData.Objective='40x';
MiscData.Experimenter='Roy Wollman';
MiscData.Experiment='testing throopi the roboscope';
MiscData.ImageName='img';

r=5;
c=5;
Pos=createAcqPattern('grid',[0 0],r,c,100,zeros(r*c,1));

ExposureDetails(1).channel='White';
ExposureDetails(1).exposure=1;
ExposureDetails(2).channel='FITC';
ExposureDetails(2).exposure=1000;

%%
T=zeros(r*c,1);
Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,'acq_simple');
removeTasks(rS,'all');
addTasks(rS,Tsks);

%%
run(rS)

