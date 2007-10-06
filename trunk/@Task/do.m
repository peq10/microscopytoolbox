function do(Tsk)
% DO the task
%     basically runs the fcn with the Tsk as input

global rS;

if isempty(Tsk)
    error('cannot do an empty task - what do you think I am?');
end
if length(Tsk)~=1
    error('Can only do one task at a time...'); 
end

disp(['Im about to perform Task with id: ' num2str(get(Tsk,'id'))]);



% check to see if task was already executed?
if Tsk.executed
    warning('Throopi:Task:singleExecution','This task was already executed, please create a new Task'); 
else
    %check if its a timed task
    tm=get(Tsk,'planetime');
    if ~isnan(tm)
        if tm > now && strcmp(get(Tsk,'LateBehavior'),'drop')
            fprintf('Task (with id %i) was droped from queue since we are late....\n',get(Tsk,'id'));
            Tsk.executed=-1;
            return
        end
        wait_time=tm-now;
        while now < tm, 
            updateStatusBar( rS,1-(tm-now)/wait_time )
            pause(0.1)
        end 
    end
    Tsk.fcn(Tsk); % call the function handle
    Tsk.executed=1;
end

disp('done');

