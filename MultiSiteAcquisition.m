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
try
    keep rS
catch
end
delete(get(0,'Children')) % a more aggressive form of close (doesn't ask for confirmation)
ScopeConfigFileName='MM_Roboscope.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
initFocalPlane(rS);
set(rS,'rootfolder','C:\TrainSet1');
set(rS,'schedulingmethod','acotsp');
set(rS,'PFS',1)
warning('off','MATLAB:divideByZero');
gotoOrigin(rS)
disp('Scope initialized');

%% User input
% Data for all channels
Channels={'FITC'};
Contents={'GFP tubulin'};
Exposure=100; %#ok<NBRAK>
Binning=1; %#ok<NBRAK>
PlateName='Test1';
WellName='Test2';

% other important data
BaseFileName='Img';

Zshift=0;

% Grid data
r=10;
c=10;
WellCenter=[0 0];
DistanceBetweenImages=200; %in microns (I think...)

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
                          'binning',Binning,...
                          'planetime',nan(length(Channels),1),...
                          'Zshift',Zshift);

%%%% Create the grid and replicate GenericTsk with few alterations

Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));

for i=1:length(Pos)
    id=getNewTaskIDs(rS);
    Tsk(i)=set(GenericTsk,'stagex',Pos(i).X,...
                          'stagey',Pos(i).Y,...
                          'stagez',Pos(i).Z,...
                          'id',id,...
                          'filename',[BaseFileName '_' num2str(id)]);
end

%% add Tasks to rS 
removeTasks(rS,'all');
addTasks(rS,Tsk);

%% set up status figures
plotPlannedSchedule(rS,1)
figure(1)
set(1,'position',[10   666   350   309],...
    'Toolbar','none','Menubar','none','name','Throopi''s route');
hold on

updateStatusBar(rS); % this should delete all old progress bars
updateStatusBar(rS,0); % create a new one
set(rS,'statusbarposition',[10 430 356 180]);

figure(3)
set(3,'position',[  376   195   894   627],...
    'Toolbar','none','Menubar','none','name','Focal Plane');

figure(4)
set(4,'position',[368   867   372   109],...
    'Toolbar','none','Menubar','none','name','Task Status');

%% do all Tasks
run(rS)

