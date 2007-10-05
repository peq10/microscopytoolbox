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
       'focusspeed',2);

disp('Scope initialized');

toc
%% User input
tic
% Data for all channels
Channels={'White'};
Contents={'Phase'};
Exposure=[6]; %#ok<NBRAK>
Binning=[2]; %#ok<NBRAK>
ExperimentName='OverNightTimeLapse-Oct4till5';

% other important data
BaseFileName='Img';

% Grid data
r=3;
c=3;
WellCenter=[0 0];
DistanceBetweenImages=1000;
T=0:300:36000;

%% create an array of Tasks
% Transform user input into variables useful to define a Task
Coll(1).CollName=ExperimentName; Coll(1).CollType='Petri'; 

for i=1:length(Channels)
    chnls(i)=struct('Number',1,'ChannelName',Channels{i}, 'Content',Contents{i});
end

%%%% Define a 'generic' Task for this well based on user data 

% start with default values for all fields
GenericTsk=Task([],'acq_simple_withFocalPlaneGuessing');

%now change Collections and their relations
GenericTsk=set(GenericTsk,'channels',chnls,...
                          'exposuretime',Exposure,...
                          'binning',Binning);

%%%% Create the grid and replicate GenericTsk with few alterations
Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));
fprintf('\n000');
for j=1:length(Pos)
    for i=1:length(T)
        id=getNewTaskIDs(rS);
        Coll(2).CollName=['Site_' num2str(j)]; Coll(2).CollType='Well'; 
        Tsk((j-1)*length(T)+i)=set(GenericTsk,'collections',Coll,...
                                              'stagex',Pos(j).X,...
                                              'stagey',Pos(j).Y,...
                                              'stagez',Pos(j).Z,...
                                              'planetime',T(i)/24/3600+now,'id',id,...
                                              'filename',[BaseFileName '_' num2str(id)]);
    end
    fprintf('\b\b\b%03d',j);
end

disp('Finished creating Tasks');
toc
%% add Tasks to rS 
tic
removeTasks(rS,'all');
addTasks(rS,Tsk);
plotPlannedSchedule(rS,1)
toc
%% do all Tasks
run(rS)

