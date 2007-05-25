function Tsk = Task(xy,fcn,dependencies,priority,UserData)
%TASK Constructor of the Task class
%   Where (n is the number iof Tasks to create):
%
%  fcn -  str or fcn_handle of the actual task execution job
%  xy  -  a 1 x 2 array of xy positions or single MetaData object
%  dependencies - a m x 2 matrix with id and delay of all dependencies
%  priority - (optional) a positive integer which is the priority of the Task, default = 1; 
%  UseData  -  (optional) additional user data that will be accessed by the TaskFcn fcn.  
                                                   

%% if MetaData is supplied, get the X,Y from the metadata object
if strcmp(class(xy),'MetaData')
    [x,y]=get(xy,'x','y');
else
    x=xy(1); 
    y=xy(2); 
end

%% create a cell array of function_handle from fcn

% if string convert to function handle
if ischar(fcn)
    fcn=str2func(fcn);
end

% check for function existance and throw an error if does not exist
if ~exist(func2str(fcn))   %#ok<EXIST>
    error('Could not create a Task object with a non existing Task Function!');
end


%% create the priority is doesn't exist and fill default value if empty
if ~exist('priority','var') || isempty(priority)
    priority=1; 
end

%% create the Tsk struct

% get the ID from the rS object
Tsk.id=getNewTaskID(rS);

% update x and y
Tsk.x=x(i);
Tsk.y=y(i);

%update priority
Tsk.priority=priority(i);

% get function handles
Tsk.fcn=fcn{i};

% metadata (if applicable)
if strcmp(class(xy),'MetaData')
    Tsk.md=xy;
else
    Tsk.md=[];
end

% run time: acqTime and stageMoveTime and fucosTime
Tsk.acqTime=0;
Tsk.focusTime=0;

% dependencies
if exist('dependencies','var') && ~isempty(dependencies)
    Tsk.dep=dependencies{i};
else
    Tsk.dep=[];
end

% executed
Tsk.executed=false;

% UserData - if not exist add empty
if exist('UserData','var')
    Tsk.UserData=UserData;
else
    Tsk.UserData=[];
end


%% create the object from the struct array
Tsk=class(Tsk,'Task');