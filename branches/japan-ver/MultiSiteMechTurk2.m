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
set(rS,'rootfolder','C:\DebugingMechTurk2');
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
r=5;
c=5;
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
GenericTsk=Task([],'acq_MechTurk');

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

%% MechTurk part
run(rS)

%% More user defenitions
ExposureZstack=500;
Zstk_N=7;
Zstk_dz=1.5;

ExposureTimeLapse=[500; 200];
TimeLapseZstak_N=3;
TimeLapseZstak_dz=3;

T=[8 4 4 ones(1,82)*2]/60/24;
%T=[1 1 1]/60/24;
ImgTubChannel=ones(size(T));
ImgTubChannel(2:2:end)=0;

%% define new GenericTaks

%% for Z stack
GenericTsk_Zstk=Task([],'acq_Zstk');

mnZ=-(Zstk_N-1)*Zstk_dz/2;
mxZ=(Zstk_N-1)*Zstk_dz/2;
Z=linspace(mnZ,mxZ,Zstk_N)*2; % The *2 is because of the Zstage bug!!!!

chnl=struct('Number',1,'ChannelName','TRITC', 'Content','Mis12 Cherry');

%now change Collections and their relations
GenericTsk_Zstk=set(GenericTsk_Zstk,'channels',chnl,...
                          'exposuretime',ExposureZstack,...
                          'planetime',now,...
                          'stagez',Z);


%% For time lapse
GenericTsk_TimeLapse=Task([],'acq_5D');

mnZ=-(TimeLapseZstak_N-1)*TimeLapseZstak_dz/2;
mxZ=(TimeLapseZstak_N-1)*TimeLapseZstak_dz/2;
Z=linspace(mnZ,mxZ,TimeLapseZstak_N)*2; % The *2 is because of the Zstage bug!!!!

clear chnls
chnls(1)=struct('Number',1,'ChannelName','TRITC', 'Content','Mis12 Cherry');
chnls(2)=struct('Number',1,'ChannelName','FITC', 'Content','GFP tubulin');

%now change Collections and their relations
T=now+cumsum(T);
UserData.T=T;
UserData.ImgTubChannel=ImgTubChannel;

GenericTsk_TimeLapse=set(GenericTsk_TimeLapse,'channels',chnls,...
                          'exposuretime',ExposureTimeLapse,...
                          'planetime',T,...
                          'stagez',Z,...
                          'timedependent',true,...
                          'UserData',UserData,...
                          'dimensionsize',[length(chnls) length(Z) length(T)]);                     

%% now get the XY positions and create the new tasks
OldTsk=getTasks(rS,'all',0);
[XY,OldIDs]=get(OldTsk,'UserData','id');

%% Create new time lapse tasks
ZTsks=[];
TimeLapseTsks=[];
for i=1:length(OldTsk)
    xy=XY{i};
    if ~isempty(xy)
        id=getNewTaskIDs(rS);
        ZTsks=[ZTsks; set(GenericTsk_Zstk,...
                          'stagex',xy(1),...
                          'stagey',xy(2),...
                          'id',id,...
                          'filename',['Stk_' num2str(OldIDs{i})])];
        id=getNewTaskIDs(rS);
        TimeLapse=set(GenericTsk_TimeLapse,...
                          'stagex',xy(1),...
                          'stagey',xy(2),...
                          'filename',['5D_' num2str(OldIDs{i})]);
         TimeLapseTsks=[TimeLapseTsks; split(TimeLapse)]; 
       
    end
end

%% add and run
set(rS,'schedulingmethod','greedy');
removeTasks(rS,'all');
addTasks(rS,ZTsks);
addTasks(rS,TimeLapseTsks);
plotPlannedSchedule(rS,1)

run(rS);
        
        
