function  run( rS )
%RUN all tasks in TaskSchedule
tm=now;
[bla,indx]=getTask(rS,'next');
do(rS.TaskBuffer(indx));

for i=2:size(rS.TaskSchedule,1)
    dt=now-tm;
    pause(rS.TaskSchedule(i,2)-dt);
    [bla,indx]=getTask(rS,'next');
    do(rS.TaskBuffer(indx));
    tm=now;
end
