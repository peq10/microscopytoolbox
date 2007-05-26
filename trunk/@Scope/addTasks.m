function addTasks(rSin,Tsks)
%ADDTASKS to the rS object

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

rS.TaskBuffer=[rS.TaskBuffer; Tsks']; 
updateTaskSchedule(rS);
