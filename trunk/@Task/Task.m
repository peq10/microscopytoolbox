function Tsk = Task(md,fcn,UserData)
%TASK Constructor of the Task class
%   Where (n is the number iof Tasks to create):
%
%  md  -  a MetaData object (basically the base class object)
%  fcn -  str or fcn_handle of the actual task execution job
%  UserData - optional user data that will be accessed.                                                   
global rS;

%% check if MetaData is supplied
% if md is empty, init it with default values
if isempty(md) 
    md=MetaData;
end

if ~strcmp(class(md),'MetaData')
    error('First argument for Task constructor must be a MetaData object');
end

% and is a scalar
if numel(md)>1
    error('Constructor for Task object can create only a single task therefore send only a single MetaDta object');
end

%% make sure fcn is a single function handle and it exist in the PATH as a .m file

% if string convert to function handle
switch class(fcn)
    case 'char'
        fcn=str2func(fcn);
    case 'function_handle'
        % check to make sure its only one
        if numel(fcn)~=1
            error('You must supply only a single function handle');
        end
    otherwise
        error('Function handle must be supplied either as a string or a function handle!');
end

% check for function existance and throw an error if does not exist
if ~exist(func2str(fcn))   %#ok<EXIST>
    error(['Could not create a Task object with a non existing Task Function!\n'...
           '%s is not a valid function'],func2str(fcn));
end

%% create the Tsk struct

% get the ID from the rS object
Tsk.id=getNewTaskIDs(rS);

% get function handles
Tsk.fcn=fcn;

% run time: acqTime and stageMoveTime and fucosTime
Tsk.acqTime=0;
Tsk.focusTime=0;
%TODO: calculate or do something with those

% executed
Tsk.executed=false;

% behavior if a timed task and is called after the time it should have happened
Tsk.LateBehavior='do'; % legel value: 'do' 'drop'

% UserData - if not exist add empty
if exist('UserData','var')
    Tsk.UserData=UserData;
else
    Tsk.UserData=[];
end


%% create the object from the struct array
Tsk=class(Tsk,'Task',md);