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
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
initFocalPlane(rS);
set(rS,'rootfolder','D:\S2data\');
set(rS,'schedulingmethod','repeated_acotsp');
set(rS,'focusrange',50);
set(rS,'xy',[0 0])
warning('off','MATLAB:divideByZero');
disp('Scope initialized');

%% User input
% Data for all channels
Channels={'white'};
Contents={'phase'};
Exposure=1; %#ok<NBRAK>
Binning=2; %#ok<NBRAK>
PlateName='Test1';
WellName='Test2';

% other important data
BaseFileName='Img';

Zshift=0;

% Grid data
r=17;
c=17;
T=0:10:30;
WellCenter=[0 0];
DistanceBetweenImages=200; %in microns (I think...)

%% create an array of Tasks
tic
% Transform user input into variables useful to define a Task
Coll(1).CollName='stam'; Coll(1).CollType='Petri'; 

for i=1:length(Channels)
    chnls(i)=struct('Number',1,'ChannelName',Channels{i}, 'Content',Contents{i});
end

% Make sure Exposure and Binning are colum vector 
Exposure=Exposure(:);
Binning=Binning(:);

%%%% Create the grid and replicate GenericTsk with few alterations
Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));
Tsks=[];
t0=now;
for i=1:length(Pos)
    % start with default values for all fields
    TskArray=Task([],'acq_goto');

    %define timelapse 
    TskArray=set(TskArray,'DimensionSize',[length(Channels),1,length(T)],...
                                'Channels',chnls,...
                                'collections',Coll,...
                                'ExposureTime',Exposure*ones(size(T)),...
                                'Binning',Binning*ones(size(T)),...
                                'stagex',repmat(Pos(i).X,length(Channels),1)*ones(size(T)),...
                                'stagey',repmat(Pos(i).Y,length(Channels),1)*ones(size(T)),...
                                'stagez',repmat(Pos(i).Z,length(Channels),1)*ones(size(T)),...
                                'planetime',repmat(T/24/3600+t0,length(Channels),1),...
                                'filename',[BaseFileName '_' num2str(i)]);
    Tsks=[Tsks; split(TskArray)];
end

disp('Finished creating Tasks');
toc
%% add Tasks to rS 
removeTasks(rS,'all');
addTasks(rS,Tsks);

%% set up status figures
plotPlannedSchedule(rS,1)
figure(1)
set(1,'position',[10   666   350   309],...
    'Toolbar','none','Menubar','none','name','Throopi''s route');
hold on

% figure(2)
% set(2,'position',[  10    97   350   295],...
%     'Toolbar','none','Menubar','none','name','Focal Plane');
% 
% plotFocalPlaneGrid(rS);

updateStatusBar(rS); % this should delete all old progress bars
updateStatusBar(rS,0); % create a new one
set(rS,'statusbarposition',[10 430 356 180]);

% figure(3)
% set(3,'position',[  376   195   894   627],...
%     'Toolbar','none','Menubar','none','name','Focal Plane');

figure(4)
set(4,'position',[368   867   372   109],...
    'Toolbar','none','Menubar','none','name','Task Status');

%% do all Tasks
% run(rS)

