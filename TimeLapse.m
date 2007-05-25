% This script is an example of how to run Throopi the Roboscope. 
% This example shows a simple time lapse and it is initialized via script
% (no gui involved...). 
% "Algorithm" outline
% =========================
% 1. Initialize the scope. 
% 2. set up acquisition details in a few 
%     3.1 Initialize a acqusition data secquence that contains the
%           position, exposures etc for all the sites within this well.
%     3.2 Initialize an acquisition sequence based on the AcqData object
%           from 3.1
%     3.3 starts and waits for the dequence to end. 
% 

%% Init Scope

% the scope configuration file that will be passed to MicroManager
ScopeConfigFileName='Scope_noStage.cfg';

% call the constractor of the Scope 
global rS; % name of the scope variable (rS=roboScope)
rS=Scope(ScopeConfigFileName);


%%  Create the structures needed for acquisitions

% Misc data - names, objective etc. 
MiscData.ProjectName='InitialTest';
MiscData.DatasetName='Tst1';
MiscData.Experimenter='Roy Wollman';
MiscData.Experiment='testing throopi the roboscope';
MiscData.ImageName='Img'; 

Pos=createAcqPattern('timelapse',[0 0 0],20); %Pattern, Where to image, Number of images

T=linspace(0,19*3,20);

% Details of all channels.
ExposureDetails(1).channel='White';
ExposureDetails(1).exposure=10;
% ExposureDetails(2).channel='DAPI';
% ExposureDetails(2).exposure=500;
% ExposureDetails(3).channel='FITC';
% ExposureDetails(3).exposure=500;
% ExposureDetails(4).channel='Cy3';
% ExposureDetails(4).exposure=500;

%% Create a series of dependent tasks
Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,'acq_simple');

% add to rS (this will automatically update the Task schedule). 
rS=addTasks(rS,Tsks); 


%% startacquisition
run(rS); 




