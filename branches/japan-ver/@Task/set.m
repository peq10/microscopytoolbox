function Tsk = set(Tsk, varargin )
% set : changes retrives the attributes of the Tsk (Tsk must be a single
%      element). Task attributes are all the MetaData attributes (since Task inherites
%       from MetaData) and a few additional ones. See HTML docs for details. 
% 
%
% example: 
%           Tsk=set(Tsk,'waittime',12)

if numel(Tsk)~=1
    error('Can only set a single Task at a time');
end

%% get the list of MetaDataAttributes from its get/set methods

persistent MetaDataAttributes;
if isempty(MetaDataAttributes)
    attrib=getClassAttributes('@MetaData');
    MetaDataAttributes={attrib.name};
    % don't allow read only properties
    MetaDataAttributes=MetaDataAttributes(~ismember({attrib.input},'READONLY'));
end

%% Set the calues
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'waittime' % units of DAYS
            Tsk.waitTime=varargin{i+1};
        case 'duration' % units of DAYS
            Tsk.duration=varargin{i+1};
        case 'timedependent' % logical (will be converted)
            Tsk.timedep=logical(varargin{i+1});
        case 'tskfcn' % could be either string or a single function handle
            if ischar(varargin{i+1})
                varargin{i+1}=str2func(varargin{i+1});
            elseif strcmp(class(varargin{i+1}),'function_handle')
                % check to make sure its only one
                if numel(varargin{i+1})~=1
                    error('You must supply only a single function handle');
                end
            else
                    error('Function handle must be supplied either as a string or a function handle!');
            end
            Tsk.fcn=varargin{i+1};
        case 'latebehavior' % a string, must be either {'do','drop'} default is 'do'
            if sum(ismember(varargin{i+1},{'do','drop'}))==0
                error('Can only set LateBehavior to DO or DROP !!');
            end
            Tsk.LateBehavior=varargin{i+1};
        case 'status'% a string, must be either {'inqueue','executed','error'} default is 'do'
            Tsk.status=varargin{i+1};
        case 'userdata' % anything you want :)
            Tsk.UserData=varargin{i+1};
        case 'id' % an integer
            if ~isinteger(id), 
                error('id must be an integer'); 
            end
            Tsk.id=varargin{i+1};
        case 'zshift' % units of \mum
            Tsk.Zshift=varargin{i+1}';
        case MetaDataAttributes % see MetaData class docs
            Tsk.MetaData=set(Tsk.MetaData,varargin{i},varargin{i+1});
        otherwise
            warning('Throopi:Task:UpdateTimes','Cannot set property %s',varargin{i});
    end
end