function [Tsks,indx] = getTasks( rS,idx )
%GETTASKS from rS. idx numerical index of task by oder (1=first end=last).
%   indx is the location of the task in the TaskBuffer
%   idx can also get the char values: 'next','last','all'

if ischar(idx)
    switch idx
        case 'next'
            idx=1;
        case 'last'
            idx=size(rS.TaskSchedule,1);
        case 'all'
            idx=1:size(rS.TaskSchedule,1);
        otherwise
    end
end

% check for ids and get them 
if isempty(rS.TaskSchedule) || idx > size(rS.TaskSchedule,1)
    error('Task requested is outside of current schedule, please update schedule and try again'); 
end
ids=rS.TaskSchedule(idx,1); 

% get TaskBuffer ids
bfrids=get(rS.TaskBuffer,'id'); 

[both_ids,indx]=intersect(bfrids,ids);
Tsks=rS.TaskBuffer(indx); 




