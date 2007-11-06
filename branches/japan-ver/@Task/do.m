function do(Tsk)
% DO the task
%     basically runs the fcn with the Tsk as input

global rS;
persistent err;

if isempty(Tsk)
    error('cannot do an empty task - what do you think I am?');
end
if length(Tsk)~=1
    error('Can only do one task at a time...'); 
end

disp(['Im about to perform Task with id: ' num2str(get(Tsk,'id')) 'and filename: ' get(Tsk,'filename')]);

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
    
    % try to perform a task
    try
        Tsk.fcn(Tsk); % call the function handle
    catch
        % ersolve the error
        UserData=get(Tsk,'UserData');
        newerr=lasterr;
        if ~strcmp(newerr,err)
            UserData.ExecutionFailure=err;
            Tsk=set(Tsk,'UserData',UserData);
            replaceTasks(rS,Tsk);
            warning(['TASK HAS FAILED WITH ERROR   ' err]);
            msgbox(err)
        end
        err=newerr;
        %% try to revcover from MM errors by unloading and loading all
        %% devices
        if~isempty(findstr(err,'mmcorej'))
            unlaod(rS);
            loadDevices(rS);
        end
        
    end
end

disp('done');

