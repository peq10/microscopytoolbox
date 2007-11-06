function  run( rSin )
%RUN all tasks in TaskSchedule

global rS;
rS=rSin;

while ~isempty(rS.TaskSchedule)
    Tsk=getTasks(rS,'next');
    updateStatusBar(rS,0)
    if ~isempty(Tsk)
        do(Tsk);
    end
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end
