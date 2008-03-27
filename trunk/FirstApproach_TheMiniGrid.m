%% Init
addpath ThirdParty\utilities\
global rS;
keep rS % delete everything but rS, rS could be a Scope or a empty double
        % from the global definition
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% if rS isn't a call the constractor of the Scope
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
set(rS,'resolveErrors',false,...
       'schedulingmethod','greedy');
initFocalPlane(rS);
disp('Scope initialized');

%% Define focus parameters
set(rS,'focusMethod','singleScanImageBased_WithMaxObjectSize');
setFocusParams(rS,'singleScanImageBased_WithMaxObjectSize',...
                  'Verbose',true,...
                  'MaxObjectSize',1000,...
                  'Range',100,...
                  'NumOfStepsInScan',[10 10],...
                  'ROI',[100 200 100 200],...
                  'AcqParam',struct('Channel','Cy3-eye','Exposure',100),...
                  'ConvKern',[0 -1 0; -1 0 1; 0 1 0])

%% Define a "Generic Task" 
GenericTsk=Task(...
                MetaData('Channels',{'Cy3','Cy5'},...
                        'Exposure',[100 100 100]),...
                'acq_minigrid');
% spawning behavior
% data related to spawned function behavior
GenericTsk=set(GenericTsk,'spawn_queue',false,... meaning it would do the spawned task immediantly and not aadd it to the queue
                          'spawn_flag',true,... it would try to spawn new tasks
                          'spawn_testFcn',@areTheTwoColoredSpotsMoving,... % function to test
                          'spawn_tskFcn','acq_burst',...
                          'spawn_filenameaddition','_burst',...
                          'spawn_attributes2modify',struct('UserData',struct('imgNumInBurst',3)),...
                          'UserData',struct('dX',100,'MiniGridSize',2)...
                          );
                      
%% define Grid
rows=3;
cols=3;
cntr=[0 0];
dX=1000;
Pos=createAcqPattern('grid',cntr,rows,cols,dX,zeros(rows*cols,1));

%% create array of tasks in grid
base_filename='img_';

for i=1:length(Pos)
    TskGrid(i)=set(GenericTsk,'stagex',Pos(i).X,...
                              'stagey',Pos(i).Y,...
                              'filename',[base_filename num2str(i)]);
end
removeTasks(rS,'all'); % clean any previous tasks that shouldn't be there
addTasks(rS,TskGrid);

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
plotInfo(3).position=[505   406   695   567];

plotInfo(4).num=4;
plotInfo(4).type='focal plane';
plotInfo(4).position=[393   100   353   222];

set(rS,'plotInfo',plotInfo);


%% run
run(rS)
