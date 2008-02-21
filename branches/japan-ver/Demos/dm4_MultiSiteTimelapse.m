%%  Multi-Site concurrnet timelapses
% Here we show how to create timelapses in two (or more) sites. 
% From the user percpective, there is almost no difference, and timelapse
% tasks are defined in almost the same way, from Roboscope perspective,
% things are a bit different. Time lapse tasks are splitted into multiple
% single timepoint atomic tasks uppon addition to the Task Buffer. 
%
% This demo also introduces the plotting scheme of Roboscope. 
% 

%% Initilize the Scope
% the scope configuration file that will be passed to MicroManager. In this
% example we are using the Demo init file Roboscope_demo.cfg. 

clear global
clear
close all 
clc
ScopeConfigFileName='Demos/Roboscope_demo.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

% Specify where to save images
set(rS,'rootfolder',[pwd filesep 'Demos' filesep 'Junk']);

% for simplicity and ease of debugging don't try to handle errors
set(rS,'resolveErrors',false);

% determine if I need to create movies of this demos and if its fake acq
set(rS,'printscreen',getpref('roboscope','moviefolder',''),...
    'fakeAcq','/home/rwollman/Photos/Patagonia');


% clean any images in that folder
delete(['Demos' filesep 'Junk' filesep '*'])

disp('Scope initialized');

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


%% Define a "Generic Task" 
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
figure(1)
plotPlannedSchedule(rS); 


%% Define what type of plotting we want
% we need to speficy the figure number, figure type and its position. If
% the tasks behaviour was defined to include plotting, it will call these
% plotting types and orginize them nucely on the screen. 
%
% Figure number of 0 creates a new figure every draw 

plotInfo(1).num=1;
plotInfo(1).type='route';
plotInfo(1).position=[10   597   350   309];

plotInfo(2).num=2;
plotInfo(2).type='planned schedule';
plotInfo(2).position=[10   200   350   309];

plotInfo(3).num=3;
plotInfo(3).type='image';
plotInfo(3).position=[380 348 894 627];

set(rS,'plotInfo',plotInfo);


%% run
run(rS)