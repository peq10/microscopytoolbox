% This script is an example of how to run Throopi the Roboscope. 
% This example shows an application in which the user choses multiple
% acquisition sites and the roboscope cycle between them to create time
% lapse movies. 
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
ScopeConfigFileName='Scope_noStage.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);


%%  Create the structures needed for acquisitions

% This will be done by a GUI in the future. 

% not sure what will get here. 
MiscData.ProjectName='InitialTest';
MiscData.DatasetName='Tst1';
MiscData.Objective='10x';
MiscData.Experimenter='Roy Wollman';
MiscData.Experiment='testing throopi the roboscope';

AcqPos=createAcqPattern('singleSpot',10,3);

% use all defualt values for acquisition functions
acqFns.acq='';
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

%% ask the user to start multiple acquisition sequences

%TODO: create user input GUI


%% ask user to click on multiple dividng cells, stop by left click
fig=figure;
b=1;
while b~=3
    uiwait(msgbox('please identify cell in scope - press button to show image'));
    img=acqImg(rS);
    imshow(img,fig);
    uiwait(msgbox('please confirm site'));
    [X,Y,Z]=get(rS,'X','Y','Z');
    AcqPos=[AcqPos; [X Y Z]];
end

%% start acquisition - create array of AcqSeq objects and start them. 

for i=1:size(AcqPos,1)
    pattern={'singleSpot',AcqPos(i,:)};
    AqSq(i)=AcqSeq(Sld,pattern,NumberOfSites,ExposureDetails,'tst');
    start(AqSq(i));
end


