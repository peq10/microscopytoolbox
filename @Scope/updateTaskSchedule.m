function updateTaskSchedule( rSin)
% updateTaskSchedule : recalculates the  schedule 
%based on the current SchedulerFcn

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% get info about tasks in buffer
PastTasks=getPastTasksDuration(rS);
durVector=PastTasks.durVector;
fncStrUnq=PastTasks.fncStrUnq;

NonExecTasks=getTasks(rS,'status','inqueue');
% get the IDs,x,y of all non-executed tasks. 
x=get(NonExecTasks,'stageX');
if iscell(x), x=[x{:}]'; end
y=get(NonExecTasks,'stagey');
if iscell(y), y=[y{:}]'; end
t=get(NonExecTasks,'planetime');
if iscell(t), t=[t{:}]'; end
id=get(NonExecTasks,'ID');
if iscell(id), id=[id{:}]'; end

fncStr=get(NonExecTasks,'fcnstr');
duration=zeros(length(NonExecTasks),1);
for i=1:length(NonExecTasks)
    ix=find(strcmp(fncStrUnq,fncStr{i})); %#ok<EFIND>
    if ~isempty(ix) && ~isempty(durVector{ix})
        dur=median(durVector{ix});
    else
        dur=get(NonExecTasks(i),'duration');
    end
    duration(i)=dur;
end

%% get current scheduling method as function handle
schedulerFcn = str2func(get(rS,'schedulingMethod')); 

%% run this function

% construct the schedule data struct
[xCurrent,yCurrent]=get(rS,'x','y');
schdle_data=struct('x',x,'y',y,'t',t,'id',id,...
               'xCurrent',xCurrent,'yCurrent',yCurrent,...
               'tCurrent',now,'duration',duration);
           
% call the scheduler function with stuct as input
rS.TaskSchedule=schedulerFcn(schdle_data);

