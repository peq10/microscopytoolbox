function Tsk = set(Tsk, varargin )
%SET method for the Task class

if numel(Tsk)~=1
    error('Can only set a single Task at a time');
end

%% load the list of MetaDataAttributes from file
% UGLY PROGRAMMING !!!!
persistent MetaDataAttributes;
if isempty(MetaDataAttributes)
    MetaDataAttributes=textread(['@Task' filesep 'MetaDataAttributes'], '%s');
end

%% Set the calues
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'waittime'
            Tsk.waitTime=varargin{i+1};
        case 'duration'
            Tsk.acqTime=varargin{i+1};
        case 'timedependent'
            Tsk.timedep=logical(varargin{i+1});
        case 'tskfcn'
            switch class(varargin{i+1})
                case 'char'
                    varargin{i+1}=str2func(varargin{i+1});
                case 'function_handle'
                    % check to make sure its only one
                    if numel(varargin{i+1})~=1
                        error('You must supply only a single function handle');
                    end
                otherwise
                    error('Function handle must be supplied either as a string or a function handle!');
            end
            Tsk.fcn=varargin{i+1};
        case 'latebehavior'
            if sum(ismember(varargin{i+1},{'do','drop'}))==0
                error('Can only set LateBehavior to DO or DROP !!');
            end
            Tsk.LateBehavior=varargin{i+1};
        case 'stagemovetime'
            Tsk.stageMoveTime=varargin{i+1};
        case 'focustime'
            Tsk.focusTime=varargin{i+1};
        case 'status'
            Tsk.status=varargin{i+1};
        case 'userdata'
            Tsk.UserData=varargin{i+1};
        case MetaDataAttributes %deligates the attributes to the MetaData class
            Tsk.MetaData=set(Tsk.MetaData,varargin{i},varargin{i+1});
        case 'id'
            Tsk.id=varargin{i+1};
        case 'zshift'
            Tsk.Zshift=varargin{i+1}';
        otherwise
            warning('Throopi:Task:UpdateTimes','Cannot set property %s',varargin{i});
    end
end