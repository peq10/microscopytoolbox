function updateTaskSchedule( rSin)
%UPDATETASKSCHEDULE update the current TaskBuffer schedule 
%based on the current SchedulerFcn

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% get info about tasks in buffer

% estimate the median duration time for each task type
ExecTsks=getTasks(rS,'executed');
fncStrUnq={};
if isempty(ExecTsks)
    medianDuration=[];
else
    [fncStr,AllDuration]=get(ExecTsks,'fcnstr','duration');
    if iscell(AllDuration)
        AllDuration=[AllDuration{:}];
    end
    if ~iscell(fncStr)
        fncStr={fncStr};

    end
    fncStrUnq=unique(fncStr);
    medianDuration=zeros(length(fncStrUnq),1);
    for i=1:length(fncStrUnq)
        medianDuration(i)=median(AllDuration(ismember(fncStr,fncStrUnq{i})));
    end
end

NonExecTasks=getTasks(rS,'nonexecuted');
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
    if ~isempty(ix) && ~isempty(medianDuration)
        dur=medianDuration(ix);
    else
        dur=get(NonExecTasks(i),'duration');
    end
    duration(i)=dur;
end

%% get current scheduling method as function handle
schedulerFcn = str2func(get(rS,'schedulingMethod')); 

%% run this function
[xCurrent,yCurrent]=get(rS,'x','y');
rS.TaskSchedule=schedulerFcn(x,y,t,id,xCurrent,yCurrent,duration,now);

