function varargout = get( Tsk,varargin )
%GET Summary of this function goes here
%   Detailed explanation goes here

%% check to see if md is an array, if so run foreach element seperatly.
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

%% get whatever is asked for a single Tsk ...
varargout={};

for i=1:length(varargin)
    switch lower(varargin{i})
        case 'id'
            varargout=[varargout; {Tsk.id}];
        case 'fcn'
            varargout=[varargout; {Tsk.fcn}];
        case 'x'
            varargout=[varargout; {Tsk.x}];
        case 'y'
            varargout=[varargout; {Tsk.y}];
        case 'metadata'
            varargout=[varargout; {Tsk.md}];
        case 'priority'
            varargout=[varargout; {Tsk.priority}];
        case 'dependencies'
            varargout=[varargout; {Tsk.dep}];
        case 'runtime'
            varargout=[varargout; {Tsk.acqTime+Tsk.focusTime}];
        case 'userdata'
            varargout=[varargout; {Tsk.UserData}];
        case 'executed'
            varargout=[varargout; {Tsk.executed}];
        otherwise
            warning('Throopi:Property:get:Task',['property: ' varargin{i} ' does not exist in Scope class']);
    end
end
            