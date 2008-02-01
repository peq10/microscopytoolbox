function varargout = get( Tsk,varargin )
% get : retrives retrives the attributes of the Tsk (Tsk could be an array)
%    Task attributes are all the MetaData attributes (since Task inherites
%    from MetaData) and a few additional ones. See HTML docs for details. 
% 
% If Tsk is an array of Tasks, the output will be a cell array for each of
% the requested attributes. 
%
% example: 
%           get(Tsk,'waittime')

if isempty(Tsk)
    varargout=cell(size(varargin));
    return
end

%% check to see if Tsk is an array, if so run foreach element seperatly.
% this chunk is a big ugly, could flip the loop and avoid the second loop,
% but who cares...
if length(Tsk)>1
    varargout={};
    s=cell(length(Tsk),length(varargin));
    for i=1:length(Tsk)
        for j=1:length(varargin)
            s{i,j}=get(Tsk(i),varargin{j});
        end
    end
    for j=1:length(varargin)
        varargout=[varargout {s(:,j)}]; %#ok<AGROW>
    end
    return
end

%% get tje list of MetaDataAttributes from its get/set methods
persistent MetaDataAttributes;
if isempty(MetaDataAttributes)
    attrib=getClassAttributes('@MetaData');
    MetaDataAttributes={attrib.name};
end
%% get whatever is asked for a single Tsk ...
varargout=cell(length(varargin),1);

for i=1:length(varargin)
    switch lower(varargin{i})
        case 'waittime' % the time (in DAYS) out of the overall time the Roboscope spent doing this task that was spent waiting for the right time to do it
            varargout{i}=Tsk.waitTime;
        case 'metadata' % returns the MetaData part of the Task object, basically it strips done all the Task functionality. 
            varargout{i}=Tsk.MetaData; 
        case 'latebehavior' % what to do when a task is overdue, should we still perform id (do - degfault) or skip it (drop)
            varargout{i}=Tsk.LateBehavior; 
        case 'id' % the Task unique identifer as supplied by the Roboscope. 
            varargout{i}=Tsk.id;
        case 'fcnstr' % A string of the Task function (same as fncstr just different spelling)
            varargout{i}=func2str(Tsk.fcn);
        case 'fncstr' % A string of the Task function (same as fcnstr just different spelling)
            varargout{i}=func2str(Tsk.fcn);
        case 'tskfcn' % a function handle of the task function. 
            varargout{i}=Tsk.fcn;
        case 'timedependent' % a flag that says whether this task should happen at a specific point in time (like in  a timlapse) or it doesn't matter (like in fixed cells). 
            varargout{i}=Tsk.timedep;
        case 'duration' % how long did it take to run this task
            varargout{i}=Tsk.duration;
        case 'userdata' % a placeholder for any data the user wants to save during a task. Since tasks are saved in rS and rS is global this provides a convinient way to store everything you need. 
            varargout{i}=Tsk.UserData;
        case 'status' % a string that specifies the status of the Task, usual values:  inqueue, executed, error. 
            varargout{i}=Tsk.status;
        case 'zshift' % a shift from the autofocus for this Task
            varargout{i}=Tsk.Zshift;
        case MetaDataAttributes %deligates the attributes to the MetaData class
            varargout{i}=get(Tsk.MetaData,varargin{i});
        otherwise
            error('Throopi:Property:get:Task',['property: ' varargin{i} ' does not exist in Task class']);
    end
end
            