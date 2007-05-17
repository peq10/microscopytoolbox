% This script is an example of how to run Throopi the Roboscope. 
% This example shows a simple time lapse and it is initialized via script
% (no gui involved...). 
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
ScopeConfigFileName='Scope_noStage.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);


%%  Create the structures needed for acquisitions

% Misc data - names, objective etc. 
MiscData.ProjectName='InitialTest';
MiscData.DatasetName='Tst1';
MiscData.Objective='10x';
MiscData.Experimenter='Roy Wollman';
MiscData.Experiment='testing throopi the roboscope';

Pos=createAcqPattern('timelapse',[0 0 0],20,5); %Where to image, Number of images, dt

% use all defualt values for acquisition functions
acqFns.acq='acq_simple.';
acqFns.astart='';
acqFns.stop='';
acqFns.error='';

ExposureDetails(1).channel='White';
ExposureDetails(1).exposure=10;
ExposureDetails(2).channel='DAPI';
ExposureDetails(2).exposure=500;
ExposureDetails(3).channel='FITC';
ExposureDetails(3).exposure=500;
ExposureDetails(4).channel='Cy3';
ExposureDetails(4).exposure=500;

%% start single time lapse

TimerName='Moshe';
start(createAcqSeqTimer(MiscData,Pos,ExposureDetails,acqFns,TimerName));




