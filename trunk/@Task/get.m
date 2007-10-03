function varargout = get( Tsk,varargin )
%GET Summary of this function goes here
%   Detailed explanation goes here

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
        varargout=[varargout {s(:,j)}];
    end
    return
end

%% load the list of MetaDataAttributes from file
MetaDataAttributes=textread(['@Task' filesep 'MetaDataAttributes'], '%s');

%% get whatever is asked for a single Tsk ...
varargout=cell(length(varargin),1);

for i=1:length(varargin)
    switch lower(varargin{i})
        case 'latebehavior'
            varargout{i}=Tsk.LateBehavior;
        case 'id'
            varargout{i}=Tsk.id;
        case 'fcn'
            varargout{i}=Tsk.fcn;
        case 'timedependent'
            % Check to see if any of the values in md planetime is non NaN. 
            % if it is this means that at least a single plane is time
            % dependent which makes the whole thing time dependent.
            tm=get(Tsk.MetaData,'planetime');
            if isempty(tm)
                error('Task has no planetime information - check how you defined it...');
            end
             varargout{i}=max(~isnan(tm));
        case 'runtime'
            varargout{i}=Tsk.acqTime+Tsk.focusTime;
        case 'userdata'
            varargout{i}=Tsk.UserData;
        case 'executed'
            varargout{i}=Tsk.executed;
        case MetaDataAttributes %deligates the attributes to the MetaData class
            varargout{i}=get(Tsk.MetaData,varargin{i});
        otherwise
            error('Throopi:Property:get:Task',['property: ' varargin{i} ' does not exist in Task class']);
    end
end
            