function Tsk = set(Tsk, varargin )
%UPDATEEXECUTIONTIME update any of the three times: stageMove, acq, focus
%   Detailed explanation goes here

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'acqtime'
            Tsk.acqTime=varargin{i+1};
        case 'stagemovetime'
            Tsk.stageMoveTime=varargin{i+1};
        case 'focustime'
            Tsk.focusTime=varargin{i+1};
        case 'metadata'
            if ~strcmp(class(varargin{i+1}),'MetaData')
                error('Task MetaData must be of class MetaData - DAh!');
            end
            Tsk.md=varargin{i+1};
        case 'executed'
            if ~islogical(varargin{i+1})
                error('executed state must be logical (true/false)');
            end
            Tsk.executed=varargin{i+1};
        case 'userdata'
            Tsk.UserData=varargin{i+1};
        otherwise
            warning('Throopi:Task:UpdateTimes','Cannot set this property');
    end
end