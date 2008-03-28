%% Init
close all
addpath ThirdParty\utilities\
global rS;
keep rS % delete everything but rS, rS could be a Scope or a empty double
        % from the global definition
ScopeConfigFileName='Roboscope_NoIntensilight.cfg';

% if rS isn't a call the constractor of the Scope
if ~strcmp(class(rS),'Scope')
    rS=Scope;%(ScopeConfigFileName);
end
set(rS,'resolveErrors',false,...
       'schedulingmethod','greedy');
initFocalPlane(rS);
disp('Scope initialized');

set(rS,'rootfolder','C:\Roy\Roboscope\Data\Test');

%% All kind of parameters that control acquisition
numOfImagesInBurstMode=50;
numOfSecTowaitBetweenmages=30;
distanceBetweenGridPoints=250;
GridSize=[3 3]; %rox by column

%% Define focus parameters
set(rS,'focusMethod','dualScanImageBased');
setFocusParams(rS,'dualScanImageBased',...
                  'SNR',1.8,...
                  'Verbose',false,...
                  'Range',[3 0.75],...
                  'NumOfStepsInScan',[15 15],...
                  'ROI',[50 450 300 450],...
                  'AcqParam',struct('Channel','Dual-Cy3-Cy5','Exposure',10,'EMGain','100'),...
                  'ConvKern',[0 -1 0; -1 0 1; 0 1 0])

%% Define a "Generic Task" 
GenericTsk=Task(...
                MetaData('Channels',{'Dual-Cy3-Cy5'},...
                        'Exposure',100),...
                'acq_simple');
            
GenericTsk=set(GenericTsk,'UserData',struct('imgNumInBurst',numOfImagesInBurstMode,...
                                            'secToWait',numOfSecTowaitBetweenmages));

%% define the two level of spawning - second level defined first 
%(since its data has to go to the first level)          

% things that are changed between first and second level
attrToModify=struct('spawn_flag',true,... changing the default (usually a spawned task doesn't spawn.
                    'spawn_testFcn',@areTheSpotsMoving,... % function to test
                    'spawn_filenameaddition','_burst',...
                    'spawn_tskFcn','acq_burst'... % in third level we burst
                    );
                
GenericTsk=set(GenericTsk,'spawn_queue',false,... meaning it would do the spawned task immediantly and not aadd it to the queue
                          'spawn_flag',true,... it would try to spawn new tasks
                          'spawn_testFcn',@areThereTwoColoredSpots,... % function to test
                          'spawn_tskFcn','acq_wait_acq',...
                          'spawn_filenameaddition','',...
                          'spawn_attributes2modify',attrToModify...
                          );
                      
%% define Grid
rows=GridSize(1);
cols=GridSize(2);
cntr=[0 0];
dX=distanceBetweenGridPoints;
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

plotInfo(2).num=2;
plotInfo(2).type='planned schedule';
plotInfo(2).position=[10   200   350   309];

plotInfo(3).num=3;
plotInfo(3).type='image';
plotInfo(3).position=[505   406   695   567];

plotInfo(1).num=4;
plotInfo(1).type='focal plane';
plotInfo(1).position=[393   100   353   222];

set(rS,'plotInfo',plotInfo);


%% run
run(rS)
