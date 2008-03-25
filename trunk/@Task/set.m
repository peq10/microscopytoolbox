function Tsk = set(Tsk, varargin )
% set : changes retrives the attributes of the Tsk (Tsk must be a single
%      element). Task attributes are all the MetaData attributes (since Task inherites
%       from MetaData) and a few additional ones. See HTML docs for details. 
% 
%
% example: 
%           Tsk=set(Tsk,'waittime',12)

global rS;

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

% We also need to keep tak of the legal set attributes for the use of
% checking while spawning, no reason to run it again every time, hence the
% persistent variable. 
persistent TaskAttributes;
if isempty(TaskAttributes)
    attrib=getClassAttributes('@Task');
    TaskAttributes={attrib.name};
    % don't allow read only properties
    TaskAttributes=TaskAttributes(~ismember({attrib.input},'READONLY'));
    TaskAttributes=TaskAttributes(~strcmp(TaskAttributes,'MetaDataAttributes'));
    TaskAttributes=[TaskAttributes MetaDataAttributes];
end

%% Set the calues
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'spawn_happened' % logical (true/false) will be converted if numeric 
            if ~islogical(varargin{i+1}) && ~isnumeric(varargin{i+1})
                error('Input for spawn flag must be logical (or numeric and then it will be converted');
            end
            Tsk.spawn.happened=logical(varargin{i+1});
        case 'spawn_flag' % logical (true/false) will be converted if numeric 
            if ~islogical(varargin{i+1}) && ~isnumeric(varargin{i+1})
                error('Input for spawn flag must be logical (or numeric and then it will be converted');
            end
            Tsk.spawn.flag=logical(varargin{i+1});
        case 'spawn_attributes2modify' % struct with legal field names
            if ~isstruct(varargin{i+1}) || ~isempty(setdiff(fieldnames(varargin{i+1}),TaskAttributes));
                error('spawn_attributes2modify MUST be a struct with field names who are legel Task/MetaData settable attributes');
            end
            Tsk.spawn.Attributes2Modify=varargin{i+1};
        case 'spawn_filenameaddition' % must be a char
            if ~ischar(varargin{i+1})
                error('spawn_filenameaddition must be a char');
            end
            Tsk.spawn.filenameAddition=varargin{i+1};
        case 'spawn_testfcn' % single filename as char or single file handle
            % convert to function handle if needed
            if ischar(varargin{i+1})
                % check to see it exist on the path
                if ~exist(varargin{i+1}) ~= 2 %#ok<EXIST> % a m-file in the path 
                    error(['Test function ' varargin{i+1} ' doesn''t exst']);
                end
                varargin{i+1}=str2func(varargin{i+1}); 
            end
            if numel(varargin{i+1})~=1
                error('you must supply a SINGLE spawn_testfcn');
            end
            Tsk.spawn.TestFcn=varargin{i+1};
        case 'spawn_tskfcn' % a legit tskfcn (e.g. a char of a filename in TaskFcns folder
            if ~ischar(varargin{i+1}) || ismember(varargin{i+1},get(rS,'avaliabletskfcns'))
                error('Spawn task function is not a legit tskfcn , see: get(rS,''avaliabletskfcns'')');
            end
            Tsk.spawn.TskFcn=varargin{i+1};
        case 'plotduringtask' % logical (true/false) will be converted if numeric
            if ~islogical(varargin{i+1}) && ~isnumeric(varargin{i+1})
                error('Input for plotDuringTask must be logical (or numeric and then it will be converted');
            end
            Tsk.plotDuringTask=logical(varargin{i+1});
        case 'writeimagetofile' % logical (true/false) will be converted if numeric
            if ~islogical(varargin{i+1}) && ~isnumeric(varargin{i+1})
                error('Input for writeimagetofile must be logical (or numeric and then it will be converted');
            end
            Tsk.writeImageToFile=logical(varargin{i+1});
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
        case 'id' % an integer (will be rounded if not)
            if ~isnumeric(varargin{i+1}), 
                error('id must be an integer'); 
            end
            Tsk.id=round(varargin{i+1});
        case 'zshift' % units of \mum
            Tsk.Zshift=varargin{i+1}';
        case MetaDataAttributes % see MetaData class docs
            Tsk.MetaData=set(Tsk.MetaData,varargin{i},varargin{i+1});
            
            % update the timedependent property of the Task if needed
            acqtm=get(Tsk.MetaData,'acqTime');
            if numel(acqtm)>1 || ~isnan(acqtm)
                Tsk=set(Tsk,'timedependent',true);
            end
        otherwise
            warning('Cannot set property %s',varargin{i});
    end
end