function [durVector,fncStrUnq]=getPastTasksDuration(rS)
% calcualtes the vector of all past duration by type
% returns two cell array - one with cevtor of durations (DAYS units!!!
% other is function names

fncStrUnq={};
durVector={};

% get past tasks
ExecTsks=getTasks(rS,'status','executed');
if isempty(ExecTsks)
    return
end

% get past tasks names and durations
[fncStr,AllDuration]=get(ExecTsks,'fcnstr','duration');
if iscell(AllDuration)
    AllDuration=[AllDuration{:}];
end
if ~iscell(fncStr)
    fncStr={fncStr};
end
fncStrUnq=unique(fncStr);
for i=1:length(fncStrUnq)
    durVector{i}=AllDuration(ismember(fncStr,fncStrUnq{i}));
end
