function  runWithoutExceptionHandling( rSin )
%RUN all tasks in TaskSchedule

global rS;
rS=rSin;
cnt=0;
while ~isempty(rS.TaskSchedule)
    cnt=cnt+1;
    if cnt==get(rS,'refreshschedule');
        fprintf('refreshing schedule\n')
        updateTaskSchedule(rS);
        cnt=0;
    end
    Tsk=getTasks(rS,'next');
    updateStatusBar(rS,0)
    t0=now;
    Tsk=do(Tsk);
    dur=now-t0;
    replaceTasks(rS,set(Tsk,'executed',1,'duration',dur));
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end
