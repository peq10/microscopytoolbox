function rS = addTasks(rS,Tsks)
%ADDTASKS to the rS object
rS.TaskBuffer=[rS.TaskBuffer; Tsks]; 
rS=updateTaskSchedule(rS);
