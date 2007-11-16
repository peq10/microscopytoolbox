%% Init Scope
% the scope configuration file that will be passed to MicroManager
try
    keep rS
catch
    clear
end
% clear persistent variables
clear functions

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
removeTasks(rS,'all');
set(rS,'rootfolder','C:\RawData\RoboData6');
set(rS,'PFS',1,'refreshschedule',10);
warning('off','MATLAB:divideByZero');
warning off
gotoOrigin(rS)
addpath ImageAnalysis
disp('Scope initialized');
tic

%% User input
% Data for all channels

DEBUG=true;

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
UserData.Zstack.T=0;

UserData.TimeLapse.Channels=[Red Green];
UserData.TimeLapse.Exposure=[500; 200];
UserData.TimeLapse.Zstack=[-1.5 1.5]; 
UserData.TimeLapse.T=cumsum(ones(1,60)*3)/1440;

if DEBUG
    UserData.NEB.T=cumsum(0.5*ones(1,10))/1440;
    set(rS,'resolveErrors',false)
    dbstop if error
else
    set(rS,'resolveErrors',true)
    dbclear if error
end

BaseFileName='Img';

% Grid data
r=32;
c=32;
WellCenter=[0 0];
DistanceBetweenImages=200; %in microns (I think...)

%% create an array of look for Prophase Tasks

%%%% Define a 'generic' Task for this well based on user data 

% start with default values for all fields
GenericTsk=Task([],'acq_lookForProphaseCells');

%now change Collections and their relations
GenericTsk=set(GenericTsk,'channels',UserData.Scan.Channels,...
                          'exposuretime',UserData.Scan.Exposure,...
                          'planetime',UserData.Scan.T,...
                          'UserData',UserData,'timedependent',false);

%%%% Create the grid and replicate GenericTsk with few alterations

Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));

for i=1:length(Pos)
    id=getNewTaskIDs(rS);
    Tsk(i)=set(GenericTsk,'stagex',Pos(i).X,...
                          'stagey',Pos(i).Y,...
                          'stagez',Pos(i).Z,...
                          'filename',[BaseFileName '_' num2str(id)]); %#ok<AGROW>
end

%% add Tasks to rS 
removeTasks(rS,'all');
set(rS,'schedulingmethod','greedy');
addTasks(rS,Tsk);


%% set up status figures
plotPlannedSchedule(rS,1)
figure(1)
set(1,'position',[10   597   350   309],...
    'Toolbar','none','Menubar','none','name','Throopi''s route');
hold on

figure(2)
set(2,'position',[ 10   246   350   309],...
    'Toolbar','none','Menubar','none','name','Focal Plane');

plotFocalPlaneGrid(rS);

figure(3)
subplot('position',[0 0 1 1])
set(3,'position',[  380   348   894   627],...
    'Toolbar','none','Menubar','none','name','Focal Plane');

figure(4)
set(4,'position',[ 10    40   364   169],...
    'Toolbar','none','Menubar','none','name','Task Status');

figure(5)
set(5,'position',[ 380    40   483   173],...
    'Toolbar','none','Menubar','none','name','Task Status');

% call the memory monitor - you can enable logging there if u want to...
mm;
%% MechTurk part

for i=1:20
    toc
    run(rS)
    addTasks(rS,Tsk);
end
set(rS,'pfs',0);
        
        
