function Tsk=do(Tsk)
% do : perform the Task (e.g. runs tskfcn when it should)
%     basically runs the fcn with the Tsk as input
%     before that it waits if needed based on the task time. Also if task
%     is overdue and has LateBehaviour drop, its ignored. In the end it
%     updates the Tsk attributes, wait_time and duration in addition to
%     whatever was changed in the task function. Tsk is then returned to
%     sender so it could be replaced with its new copy. 
%
%     In most cases, do is called via he Roboscope run method, but it is
%     possible to run Tasks outside the schedule but just calling the do
%     method. 
%
% example: 
%          do(Tsk); 

if isempty(Tsk)
    error('cannot do an empty task - what do you think I am?');
end
if length(Tsk)~=1
    error('Can only do one task at a time...'); 
end

fprintf(['--------------------\nTask id: ' num2str(get(Tsk,'id')) '\nfunction: ' func2str(get(Tsk,'tskfcn')) '\nfilename: ' get(Tsk,'filename') '\ntime: ' datestr(now,0) '\n']);

% check to see if task was already executed?
if strcmp(get(Tsk,'status'),'inqueue')
    wait_time=0;
    % check if its a timed task
    if get(Tsk,'timedependent');
        tm=get(Tsk,'acqtime');
        if tm > now && strcmp(get(Tsk,'LateBehavior'),'drop')
            fprintf('Task (with id %i) was droped from queue since we are late....\n',get(Tsk,'id'));
            Tsk.executed=-1;
            return
        end
        wait_time=tm-now;
        if wait_time > 0
            fprintf('waiting for %s ',datestr(wait_time,13))
        end
        while now < tm
            pause(0.1)
            fprintf('.')
        end
        disp(sprintf('Task time %s',datestr(tm,0)))
    end

    % perform the task
    t0=now;
    Tsk=Tsk.fcn(Tsk); % call the function handle
    dur=now-t0;
    Tsk=set(Tsk,'duration',dur,'waittime',wait_time);
end

disp('done');

