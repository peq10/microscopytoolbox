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
        otherwise
            warning('Throopi:Task:UpdateTimes','Cannot set this property');
    end
end