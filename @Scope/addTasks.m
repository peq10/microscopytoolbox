function addTasks(rSin,Tsks)
% addTasks : add the tasks in the array Tsks to the rS object
% upon addition, each task recives an identifier and its status is 
% updated to 'inqueue'.
% 
% After addition of tasks the schedule is updated. 
%
% example: 
%          addTasks(rS,Tsk);

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% add ids to Tsks
for i=1:length(Tsks)
    Tsks(i)=set(Tsks(i),'id',get(rS,'newTaskID'),'status','inqueue');
end


%% add Tasks
rS.TaskBuffer=[rS.TaskBuffer; Tsks(:)]; 

%% update schedule nased on current methods
updateTaskSchedule(rS);
