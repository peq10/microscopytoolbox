function do(Tsk)
% DO the task
%     basically runs the fcn with the Tsk as input

if length(Tsk)~=1
    error('Can only do one task at a time...'); 
end

% check to see if task was already executed?

if Tsk.executed
    warning('Throopi:Task:singleExecution','This task was already executed, please create a new Task'); 
else
    Tsk.fcn(Tsk); 
    Tsk.executed=true;
end

