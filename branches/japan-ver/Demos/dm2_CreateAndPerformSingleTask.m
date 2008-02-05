%%  Basic use of Task objects
% Here we show what could be accomplished using Tasks. The demo is very
% similar to the previous one (dm1_...) but it is performing the single
% site three channels acquisition by defining a Task object, uploading this
% task to the Scope task buffer and running the Scope. 

%% Initilize the Scope
% the scope configuration file that will be passed to MicroManager. In this
% example we are using the Demo init file Roboscope_demo.cfg. 

clear all
close all 
clc
ScopeConfigFileName='Demos/Roboscope_demo.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

% Specify where to save images
set(rS,'rootfolder',[pwd filesep 'Demos' filesep 'Junk'],'schedulingmethod','asadded');

% clean any images in that folder
delete(['Demos' filesep 'Junk' filesep '*'])

disp('Scope initialized');

%% Create a single task 
% The task is a simple: 
% 
% * goto x,y position
% * capture a multi-channel image
% * write to disk.
%
% See doc for acq_simple for more details. 

Tsk=Task([],'acq_simple');

Tsk=set(Tsk,'stagex',100,...
            'stagey',100,...
             'filename','stam.tiff',...
            'Channels',{'FITC','Cy3','DAPI'},...
            'Exposure',[40 30 20],...
            'plotDuringTask',false);


%% add the Task
% addition of tasks will implicitly call the default schedular, in this
% case its of no sighnificance since there is only a single object. 
addTasks(rS,Tsk);

%% run
run(rS)

%% get an updated Task
% During the run many attributes of Tsk where changed. Therefore its a good
% idea if we want to keep in using it, to get the updated version from rS.
% In this case this is necessary since key attributes where changed
% (specifically DimensionSize). To read the image properly we need to have
% the updated object. 

Tsk=getTasks(rS,'filename',get(Tsk,'filename'));

%% read the image from disk

img=readTiff(Tsk,get(rS,'rootFolder'));
imshow(img,[])

%% close gracefully
unload(rS)
