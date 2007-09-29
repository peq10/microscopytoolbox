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
keep rS
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
set(rS,'rootfolder','D:\GiardiaDataBuffer\');
disp('Scope initialized');

%% User input
% Data for all channels
Channels={'White'};
Contents={'Phase'};
Exposure=[5]; %#ok<NBRAK>
Binning=[1]; %#ok<NBRAK>
PlateName='Test1';
WellName='Test2';

% other important data
BaseFileName='Img';

% Grid data
r=3;
c=3;
WellCenter=[0 0];
DistanceBetweenImages=100;

%% create an array of Tasks
% Transform user input into variables useful to define a Task
Coll(1).CollName=PlateName; Coll(1).CollType='Plate'; 
Coll(2).CollName=WellName; Coll(2).CollType='Well'; 
Rel.sub=2; Rel.dom=1;

for i=1:length(Channels)
    chnls(i)=struct('Number',1,'ChannelName',Channels{i}, 'Content',Contents{i});
end

%%%% Define a 'generic' Task for this well based on user data 

% start with default values for all fields
GenericTsk=Task([],'acq_simple');

%now change Collections and their relations
GenericTsk=set(GenericTsk,'collections',Coll,...
                          'Relations',Rel,...
                          'channels',chnls,...
                          'exposuretime',Exposure,...
                          'binning',Binning);

%%%% Create the grid and replicate GenericTsk with few alterations

Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,nan(r*c,1));

for i=1:length(Pos)
    id=getNewTaskIDs(rS);
    Tsk(i)=set(GenericTsk,'stagex',repmat(Pos(i).X,1,length(Channels)),...
                          'stagey',repmat(Pos(i).Y,1,length(Channels)),...
                          'stagez',zeros(length(Channels),1),...
                          'id',id,...
                          'filename',[BaseFileName '_' num2str(id)]);
end

%% add Tasks to rS 
removeTasks(rS,'all');
addTasks(rS,Tsk);
plotPlannedSchedule(rS,3)
figure(3)
hold on

%% do all Tasks
run(rS)

