function  runWithoutExceptionHandling( rSin )
%RUN all tasks in TaskSchedule

global rS;
rS=rSin;

while ~isempty(rS.TaskSchedule)
    Tsk=getTasks(rS,'next');
    updateStatusBar(rS,0)
    t0=now;
    Tsk=do(Tsk);
    dur=now-t0;
    set(Tsk,'duration',dur);
    replaceTasks(rS,set(Tsk,'executed',true));
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end
