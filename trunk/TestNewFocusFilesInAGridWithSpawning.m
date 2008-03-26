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
set(rS,'resolveErrors',false);
disp('Scope initialized');

%% Define focus parameters
set(rS,'focusMethod','dualScanImageBased');
setFocusParams(rS,'dualScanImageBased','Verbose',true)
setFocusParams(rS,'dualScanImageBased','Range',50)
setFocusParams(rS,'dualScanImageBased','NumOfStepsInScan',[10 10])
setFocusParams(rS,'dualScanImageBased','ROI',[100 200 100 200])
setFocusParams(rS,'dualScanImageBased','AcqParam',struct('Channel','Cy3-eye','Exposure',100))
setFocusParams(rS,'dualScanImageBased','ConvKern',[0 -1 0; -1 0 1; 0 1 0])

%% Define a "Generic Task" 
GenericTsk=Task(...
                MetaData('Channels',{'FITC','Cy3','Cy5'},...
                        'Exposure',[100 100 100]),...
                'acq_simple');
% spawning behavior
t=0:10:60; 
GenericTsk=set(GenericTsk,'spawn_queue',false,... meaning it would do the spawned task immediantly and not aadd it to the queue
                          'spawn_flag',true,... it would try to spawn new tasks
                          'spawn_testFcn',@(x) deal(rand<0,[]),... % function to test
                          'spawn_tskFcn','acq_simple',...
                          'spawn_filenameaddition','_timelapse',...
                          'spawn_attributes2modify',struct('acqTime',t)...
                          );
                      
%% define Grid
rows=2;
cols=2;
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
plotInfo(3).position=[513   272   830   703];

set(rS,'plotInfo',plotInfo);


%% run
run(rS)
