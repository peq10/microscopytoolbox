% This script is an example of how to run Throopi the Roboscope. 
% It will acquire a time lapse movie in single location (single task) 
%
% The followig code is divided into cells, they: 
% 1. Initialize the scope
% 2. get user data
% 3. create a single Task with multiple timepoints of Tasks (Tsk) (two step, first define whats the same for all tasks and then
% 4. add Tsk to rS 
% 5. run

%% Init Scope
% the scope configuration file that will be passed to MicroManager
keep rS
delete(get(0,'Children')) % a more aggressive form of close (doesn't ask for confirmation)
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
set(rS,'rootfolder','D:\GiardiaDataBuffer\');
disp('Scope initialized');

%% User input
% Data for all channels
Channels={'White'};
Contents={'Phase'};
Exposure=[5]; %#ok<NBRAK>
Binning=[1]; %#ok<NBRAK>
ExperimentName='Tst2';

% other important data
BaseFileName='Stk';

% Stage position
x=0; y=0; z=0; 

% Time
T=0:5:30;

%% create the time lapse Task
% Transform user input into variables useful to define a Task
Coll(1).CollName=PlateName; Coll(1).CollType='Plate'; 
Coll(2).CollName=WellName; Coll(2).CollType='Well'; 
Rel.sub=2; Rel.dom=1;

for i=1:length(Channels)
    chnls(i)=struct('Number',1,'ChannelName',Channels{i}, 'Content',Contents{i});
end

%%%% Define a 'generic' Task for this well based on user data 

% start with default values for all fields
Tsk=Task([],'acq_simple');

%now change Collections and their relations
Tsk=set(Tsk,'collections',Coll,...
                          'Relations',Rel,...
                          'channels',chnls,...
                          'exposuretime',Exposure,...
                          'binning',Binning,...
                          'stagex',repmat(Pos(i).X,1,length(Channels)),...
                          'stagey',repmat(Pos(i).Y,1,length(Channels)),...
                          'stagez',zeros(length(Channels),1),...
                          'id',id,...
                          'filename',[BaseFileName '_' num2str(id)]);
                      
                      