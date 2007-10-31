function updateTaskSchedule( rSin)
%UPDATETASKSCHEDULE update the current TaskBuffer schedule 
%based on the current SchedulerFcn

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% get info about tasks in buffer

% get the IDs,x,y of all non-executed tasks. 
x=[];
y=[]; 
t=[];
id=[];
duration=[];
for i=1:length(rS.TaskBuffer)
    exec=get(rS.TaskBuffer(i),'executed'); 
    if ~exec
        x=[x; get(rS.TaskBuffer(i),'stageX')]; 
        y=[y; get(rS.TaskBuffer(i),'stageY')];
        t=[t; get(rS.TaskBuffer(i),'planetime')];
        id=[id; get(rS.TaskBuffer(i),'ID')];
        duration=[duration; get(rS.TaskBuffer(i),'duration')];
    end
end

%% get current scheduling method as function handle
schedulerFcn = str2func(get(rS,'schedulingMethod')); 

%% run this function
[xCurrent,yCurrent]=get(rS,'x','y');
rS.TaskSchedule=schedulerFcn(x,y,t,id,xCurrent,yCurrent,duration,now);

