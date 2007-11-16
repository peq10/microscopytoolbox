function addTasks(rSin,Tsks)
%ADDTASKS to the rS object

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% add ids to Tsks
for i=1:length(Tsks)
    Tsks(i)=set(Tsks(i),'id',getNewTaskIDs(rS),'status','inqueue');
end


%% add Tasks
rS.TaskBuffer=[rS.TaskBuffer; Tsks(:)]; 

%% update schedule nased on current methods
updateTaskSchedule(rS);
