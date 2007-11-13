%% Init Scope
% the scope configuration file that will be passed to MicroManager
try
    keep rS
catch
    clear
end

delete(get(0,'Children')) % a more aggressive form of close (doesn't ask for confirmation)
ScopeConfigFileName='MM_Roboscope.cfg';

Red=struct('Number',1,'ChannelName','TRITC', 'Content','');
Green=struct('Number',1,'ChannelName','FITC', 'Content','');

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
initFocalPlane(rS);
set(rS,'rootfolder','C:\RawData\RealData19');
set(rS,'schedulingmethod','greedy');
set(rS,'PFS',1)
warning('off','MATLAB:divideByZero');
gotoOrigin(rS)
addpath ImageAnalysis
disp('Scope initialized');

%% User input
% Data for all channels

UserData.Scan.Channels=Green;
UserData.Scan.Exposure=100;
UserData.Scan.Zstack=0;
UserData.Scan.T=NaN;

UserData.NEB.Channels=Green;
UserData.NEB.Exposure=100;
UserData.NEB.Zstack=0;
UserData.NEB.T=cumsum(6*ones(1,10))/1440;

UserData.Zstack.Channels=Red;
UserData.Zstack.Exposure=1200;
UserData.Zstack.Zstack=-9.8:1.4:9.8; 
UserData.Zstack.T=NaN;

UserData.TimeLapse.Channels=[Red Green];
UserData.TimeLapse.Exposure=[500; 200];
UserData.TimeLapse.Zstack=[-1.5 1.5]; 
UserData.TimeLapse.T=ones(1,60)*3;

BaseFileName='Img';

% Grid data
r=12;
c=12;
WellCenter=[0 0];
DistanceBetweenImages=200; %in microns (I think...)

%% create an array of look for Prophase Tasks

%%%% Define a 'generic' Task for this well based on user data 

% start with default values for all fields
GenericTsk=Task([],'acq_lookForProphase');

%now change Collections and their relations
GenericTsk=set(GenericTsk,'channels',UserData.Scan.Channels,...
                          'exposuretime',UserData.Scan.Exposure,...
                          'planetime',UserData.Scan.T);

%%%% Create the grid and replicate GenericTsk with few alterations

Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));

for i=1:length(Pos)
    id=getNewTaskIDs(rS);
    Tsk(i)=set(GenericTsk,'stagex',Pos(i).X,...
                          'stagey',Pos(i).Y,...
                          'stagez',Pos(i).Z,...
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

figure(2)
set(2,'position',[  10    97   350   295],...
    'Toolbar','none','Menubar','none','name','Focal Plane');

plotFocalPlaneGrid(rS);

updateStatusBar(rS); % this should delete all old progress bars
updateStatusBar(rS,0); % create a new one
set(rS,'statusbarposition',[10 430 356 180]);

figure(3)
subplot('position',[0 0 1 1])
set(3,'position',[  376   195   894   627],...
    'Toolbar','none','Menubar','none','name','Focal Plane');

figure(4)
set(4,'position',[368   867   572   109],...
    'Toolbar','none','Menubar','none','name','Task Status');

%% MechTurk part
run(rS)
set(rS,'pfs',0);
        
        
