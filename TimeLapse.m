% This script is an example of how to run Throopi the Roboscope. 
% Performed setps
% 1. Initialize the scope. 
% 2. get some acuisition details 
% 3. create and add tasks base on step 2. 
% 4. run Throopi. 

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

Pos=createAcqPattern('grid',[0 0],10,10,1000,zeros(100,1)); %Pattern, Where to image, Number of images

T=linspace(0,19*3,100);

% Details of all channels.
ExposureDetails=[];
ExposureDetails(1).channel='White';
ExposureDetails(1).exposure=10;
ExposureDetails(1).channel='Cy3';
ExposureDetails(1).exposure=300;

% ExposureDetails(2).channel='DAPI';
% ExposureDetails(2).exposure=500;


%% Create a series of dependent tasks
Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,'acq_simple');

% add to rS (this will automatically update the Task schedule). 
addTasks(rS,Tsks); 


%% startacquisition
run(rS); 




