%% Demo combining time lapse with scan
% we create both time lapse and grid of non timed tasks and combine them togather. 

%% Initilize the Scope
% the scope configuration file that will be passed to MicroManager. In this
% example we are using the Demo init file Roboscope_demo.cfg. 

clear global
clear 
close all 
clc
ScopeConfigFileName=fullfile('Demos','Roboscope_demo.cfg');

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

% Specify where to save images
set(rS,'rootfolder',[pwd filesep 'Demos' filesep 'Junk']);

% refresh schedule every 10 taksks
% set(rS,'refreshschedule',10);

% determine if I need to create movies of this demos and if its fake acq
set(rS,'printscreen',getpref('roboscope','moviefolder',''),...
    'fakeAcq',['Demos' filesep 'Patagonia']);

% clean any images in that folder
delete(['Demos' filesep 'Junk' filesep '*'])

disp('Scope initialized');

%% Create the grid points
% Create the x-y grid of Task position using the createAcqPattern function
% We create a 5x5 grid where distance between sites is 1000 um. The
% center of the grid is at [0 0]

rows=5;
cols=5;
cntr=[0 0];
dX=1000;
Pos=createAcqPattern('grid',cntr,rows,cols,dX,zeros(rows*cols,1));

%% Define a "Generic Task" 
% Note that we are combining the constructor calls for the MetaData object
% and the Task object. This way the Task gets the relevent MetaData
% attributes in addition to the task function. 

GenericTsk=Task(...
                MetaData('Channels',{'FITC','Cy3','DAPI'},...
                        'Exposure',[40 30 20]),...
                'acq_simple');
            
%% Create an array of Tasks 
% This array is generated based on the Generic Task and the Pos that where
% created above. The Only differences between these tasks are going to be
% the x,y posititions and the filename. 

base_filename='img_';

for i=1:length(Pos)
    TskGrid(i)=set(GenericTsk,'stagex',Pos(i).X,...
                              'stagey',Pos(i).Y,...
                              'filename',[base_filename num2str(i)]);
end

%% add the Task
% addition of tasks will implicitly call the default schedular. In this case
% it is important how they are added. We start with not scheduling methods 
% and addition in random order) and then show two other better scheduling 
% methods greeydy and acotsp 

% set shceduling methods to "Null"
set(rS,'schedulingmethod','greedy');
addTasks(rS,TskGrid(randperm(length(TskGrid))));
set(rS,'schedulingmethod','heuristicFrogLeaps')

%% Define few variables that will control where and when to image. 
% the unit for all variables must be the same that are used by rS. 
% use |units=get(rS,'units')| to find out what those units are.
x=[-100 100 300];
y=[400 135 890];
z=[0 0 0];
t=0:10:30;  % in seconds (that what rS is defalut units are for acquisition) 
t=transformUnits(rS,'acqTime',t);

%%
% NOTE: Acquitision Time must transformed to rS internal units which are 
% the time that passed since 0:00:00 1-1-0000. 
%
% You can either use units of DAYS or supply the time in rS default units
% (seconds, or whtever you speficy it to be) and that use unit
% tranformation. 
%       


%% Define a new "Generic Task" for the time lapse
% Note that we are combining the constructor calls for the MetaData object
% and the Task object. This way the Task gets the relevent MetaData
% attributes in addition to the task function. 
%
% Note: to create the timelapse all we need to do is define a vector 
% of timepoints that we want the time lapse movie in. 
% 
% Note: you can change the units that Roboscope talks in. 

GenericTsk=Task(...
                MetaData('Channels',{'FITC','Cy3','DAPI'},...
                        'Exposure',[40 30 20],...
                         'acqTime',t,...
                         'stagez',0),...
                'acq_simple');

%% Create an array of Tasks 
% This array is generated based on the Generic Task and the x,y,z that where
% created above. The Only differences between these tasks are going to be
% the x,y posititions and the filename. 

base_filename='img_';

for i=1:length(x)
    TskGrid(i)=set(GenericTsk,'stagex',x(i),...
                              'stagey',y(i),...
                              'filename',[base_filename num2str(i)]);
end

%% add the Task
% addition of tasks will implicitly call the default schedular. In this case
% it is important how they are added. We start with not scheduling methods 
% and addition in random order) and then show two other better scheduling 
% methods greeydy and acotsp 

addTasks(rS,TskGrid(randperm(length(TskGrid))));

plotPlannedSchedule(rS);

%%
plotInfo(1).num=1;
plotInfo(1).type='route';
plotInfo(1).position=[10   597   450   309];

plotInfo(2).num=2;
plotInfo(2).type='planned schedule';
plotInfo(2).position=[10   200   350   309];

plotInfo(3).num=3;
plotInfo(3).type='image';
plotInfo(3).position=[513   272   830   703];

set(rS,'plotInfo',plotInfo);

%% 
run(rS)
