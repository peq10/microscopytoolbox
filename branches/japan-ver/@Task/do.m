function Tsk=do(Tsk)
% DO the task
%     basically runs the fcn with the Tsk as input

global rS;

if isempty(Tsk)
    error('cannot do an empty task - what do you think I am?');
end
if length(Tsk)~=1
    error('Can only do one task at a time...'); 
end

fprintf(['--------------------\nTask id: ' num2str(get(Tsk,'id')) '\nfunction: ' func2str(get(Tsk,'fcn')) '\nfilename: ' get(Tsk,'filename') '\ntime: ' datestr(now,0) '\n']);

% check to see if task was already executed?
if Tsk.executed
    warning('Throopi:Task:singleExecution','This task was already executed, please create a new Task');
else
    %check if its a timed task
    if get(Tsk,'timedependent');
        tm=get(Tsk,'planetime');
        if tm > now && strcmp(get(Tsk,'LateBehavior'),'drop')
            fprintf('Task (with id %i) was droped from queue since we are late....\n',get(Tsk,'id'));
            Tsk.executed=-1;
            return
        end
        wait_time=tm-now;
        while now < tm
            updateStatusBar( rS,1-(tm-now)/wait_time )
            pause(0.1)
        end
        disp(sprintf('Task time %s',datestr(tm,0)))
    end

    % perform the task
    t0=now;
    Tsk=Tsk.fcn(Tsk); % call the function handle
    dur=now-t0;
    Tsk=set(Tsk,'duration',dur);
end

disp('done');

