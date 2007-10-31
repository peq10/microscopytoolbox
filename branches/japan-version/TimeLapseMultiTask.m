% This script is an example of how to run Throopi the Roboscope. 
% It will acruiq a grid of image (suitable for a single well)
%
% The followig code is divided into cells, they: 
% 1. Initialize the scope
% 2. get user data
% 3. create an array of Tasks (Tsk) for this well (two step, first define whats the same for all tasks and then
% 4. add Tsk to rS 
% 5. run

%% Init Scope
% the scope configuration file that will be passed to MicroManager
try keep rS, catch disp('rS does not exist, creating one'); end 
tic
delete(get(0,'Children')) % a more aggressive form of close (doesn't ask for confirmation)
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end

% a list of things that are specific for this script: 
set(rS,'rootfolder','D:\S2data\',...
       'schedulingmethod','greedy',...
       'focusrange',50,...
       'focusspeed',2,...
       'channel','close'); %channel is set to close and will be reopened for 
initFocalPlane(rS);
warning off MATLAB:divideByZero
disp('Scope initialized');

toc
%% User input
tic
% Data for all channels
Channels={'White'};
Contents={'Phase'};
Exposure=[6]'; %#ok<NBRAK>
Binning=[2]'; %#ok<NBRAK>
ExperimentName='OverNightTimeLapse-Oct4till5';

% other important data
BaseFileName='Stack';

% Grid data
r=1;
c=2;
WellCenter=[0 0];
DistanceBetweenImages=100;
T=0:60:60;
N=length(T);

%% create an array of Tasks
tic
% Transform user input into variables useful to define a Task
Coll(1).CollName=ExperimentName; Coll(1).CollType='Petri'; 

for i=1:length(Channels)
    chnls(i)=struct('Number',1,'ChannelName',Channels{i}, 'Content',Contents{i});
end

% Make sure Exposure and Binning are colum vector 
Exposure=Exposure(:);
Binning=Binning(:);

%%%% Create the grid and replicate GenericTsk with few alterations
Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));
Tsks=[];
for i=1:length(Pos)
    % start with default values for all fields
    TskArray=Task([],'acq_simple_withFocalPlaneGuessing');

    %define timelapse 
    TskArray=set(TskArray,'DimensionSize',[length(Channels),1,length(T)],...
                                'Channels',chnls,...
                                'collections',Coll,...
                                'ExposureTime',Exposure*ones(size(T)),...
                                'Binning',Binning*ones(size(T)),...
                                'stagex',repmat(Pos(i).X,length(Channels),1)*ones(size(T)),...
                                'stagey',repmat(Pos(i).Y,length(Channels),1)*ones(size(T)),...
                                'stagez',repmat(Pos(i).Z,length(Channels),1)*ones(size(T)),...
                                'planetime',repmat(T/24/3600+now,length(Channels),1),...
                                'filename',[BaseFileName '_' num2str(i)]);
    Tsks=[Tsks; split(TskArray)];
end

disp('Finished creating Tasks');
toc
%% add Tasks to rS 
tic
removeTasks(rS,'all');
addTasks(rS,Tsks);
plotPlannedSchedule(rS,1)
disp('Added Tasks top Scope');
toc
%% do all Tasks
run(rS)

