%%  Slide scanning with Image based task spawning - time lapse example
% Here we show how to to scan a slide and decide based on image content
% whether to start a timelapse or not. 
%
% Note that the main difference between dm5 and dm6 is the scheduling
% method and the fact that the time dependent tasks are repeated. 
% 

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

% for simplicity and ease of debugging don't try to handle errors
set(rS,'resolveErrors',false);

% determine if I need to create movies of this demos and if its fake acq
set(rS,'printscreen',getpref('roboscope','moviefolder',''),...
    'fakeAcq',['Demos' filesep 'Patagonia']);

% set schdeuler to be the most fitting for these type of combined scane /
% timelapse schedule.
set(rS,'schedulingmethod','greedy','refreshschedule',20)


% clean any images in that folder
delete(['Demos' filesep 'Junk' filesep '*'])

disp('Scope initialized');

%% Create the grid points
% Create the x-y grid of Task position using the createAcqPattern function
% We create a 5x5 grid where distance between sites is 1000 um. The
% center of the grid is at [0 0]

rows=10;
cols=10;
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
            
%% set the Task spawning behaviour
% Define at which conditions to spawn a new task and what type of task to
% spawn with what criteria. Overall there are five spawn related attrubutes
% to define: flag, testFcn, tskFcn, filenameaddition, attribute2modify
%
% In this example we use a "fake" checkFunction to decide if a new task
% should be spawned. Hey, this is just a demo :)
%
% Note: that even the annonymous fake test must return two output arguments
% one for the true/false flag and the other the extra data. Here I'm using
% deal to do that. 

%  
t=0:5:20;

% In general checkFunction should return a scalar logical. 
GenericTsk=set(GenericTsk,'spawn_flag',true,...
                          'spawn_testFcn',@(x) deal(rand<0.2,[]),...
                          'spawn_tskFcn','acq_Zstack',...
                          'spawn_filenameaddition','_TimeLapse',...
                          'spawn_attributes2modify',struct('acqtime',t,...
                                                           'stagez',0)...
                          );
                      
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
addTasks(rS,TskGrid(randperm(length(TskGrid))));

%% Define what type of plotting we want
% we need to speficy the figure number, figure type and its position. If
% the tasks behaviour was defined to include plotting, it will call these
% plotting types and orginize them nucely on the screen. 
%
% Figure number of 0 creates a new figure every draw 

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


%% run
run(rS)
