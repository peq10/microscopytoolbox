function  run( rS )
%RUN all tasks in TaskSchedule

while ~isempty(rS.TaskSchedule)
    [bla,indx]=getTasks(rS,'next');
    do(rS.TaskBuffer(indx));
    % remove the Task from the schedule
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end
