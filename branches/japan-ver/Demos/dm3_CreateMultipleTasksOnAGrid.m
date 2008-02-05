%%  Working With Many Tasks
% Here we show what could be accomplished using multiple Tasks. 
% we create an array of tasks on a grid upload and run them. 
% 
% This demo demostrates the use of scheduling algorithms
%

%% Initilize the Scope
% the scope configuration file that will be passed to MicroManager. In this
% example we are using the Demo init file Roboscope_demo.cfg. 

clear 
close all 
clc
ScopeConfigFileName='Demos/Roboscope_demo.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

% Specify where to save images
set(rS,'rootfolder',[pwd filesep 'Demos' filesep 'Junk']);

% clean any images in that folder
delete(['Demos' filesep 'Junk' filesep '*'])

disp('Scope initialized');

%% Create the grid points
% Create the x-y grid of Task position using the createAcqPattern function
% We create a 5x5 grid where distance between sites is 1000 um. The
% center of the grid is at [0 0]

rows=7;
cols=7;
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
            
%%
% setting plotting to off, just to make things simple. It would be
% explained in demo 4+ 
GenericTsk=set(GenericTsk,'plotDuringTask',false);

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
set(rS,'schedulingmethod','asadded');
addTasks(rS,TskGrid(randperm(length(TskGrid))));
figure(1)
plotPlannedSchedule(rS); 

%% Alternative schedulers
% We could also use other alternative schedulers. Lets see what we have
% defined :

% List the avaliable schedualing algorithms
schAlg=get(rS,'AvaliableSchedulers');

% use matlab's regexp to get a nice list
disp(regexprep([schAlg{:}],'.m',char(13)))

%%
% From these methods, the ones that are relevant are the:
% 
%%
% 
% * acotsp
% * asadded
% * external_file
% * greedy
%
%%
%  The over methods (repeated_acotsp and heuristicFromLeaps) are intended
%  to use in cases where are time dependent tasks. 
%  

%% Switch scheduling methods

%%
% *Greedy:*

set(rS,'schedulingmethod','greedy');
updateTaskSchedule(rS);
figure(2)
plotPlannedSchedule(rS); 

%%
% *Solving Traveling Saleperson probmen (TSP) using Ant Colont Optimization (ACO)*

set(rS,'schedulingmethod','acotsp');
updateTaskSchedule(rS);
figure(3)
plotPlannedSchedule(rS); 

%% run
run(rS)
