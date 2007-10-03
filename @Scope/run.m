function  run( rSin )
%RUN all tasks in TaskSchedule

global rS;
rS=rSin;

while ~isempty(rS.TaskSchedule)
    [Tsk,indx]=getTasks(rS,'next');
    do(Tsk);
    % remove the Task from the schedule
    indxtokeep=1:length(rS.TaskSchedule);
    indxtokeep=setdiff(indxtokeep,indx);
    rS.TaskSchedule=rS.TaskSchedule(indxtokeep);
end
