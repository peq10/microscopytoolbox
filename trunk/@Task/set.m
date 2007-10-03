function Tsk = set(Tsk, varargin )
%SET method for the Task class

if numel(Tsk)~=1
    error('Can only set a single Task at a time');
end

%% load the list of MetaDataAttributes from file
MetaDataAttributes=textread(['@Task' filesep 'MetaDataAttributes'], '%s');

%% Set the calues
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'latebehavior'
            if sum(ismember(varargin{i+1},{'do','drop'}))==0
                error('Can only set LateBehavior to DO or DROP !!');
            end
            Tsk.LateBehavior=varargin{i+1};
        case 'acqtime'
            Tsk.acqTime=varargin{i+1};
        case 'stagemovetime'
            Tsk.stageMoveTime=varargin{i+1};
        case 'focustime'
            Tsk.focusTime=varargin{i+1};
        case 'executed'
            if ~islogical(varargin{i+1})
                error('executed state must be logical (true/false)');
            end
            Tsk.executed=varargin{i+1};
        case 'userdata'
            Tsk.UserData=varargin{i+1};
        case MetaDataAttributes %deligates the attributes to the MetaData class
            Tsk.MetaData=set(Tsk.MetaData,varargin{i},varargin{i+1});
        case 'id'
            Tsk.id=varargin{i+1};
        otherwise
            warning('Throopi:Task:UpdateTimes','Cannot set property %s',varargin{i});
    end
end