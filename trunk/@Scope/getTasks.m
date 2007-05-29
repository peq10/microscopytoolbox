function [Tsks,indx] = getTasks( rS,idx,bysch )
%GETTASKS from rS. idx numerical index of task by oder (1=first end=last).
%   indx is the location of the task in the TaskBuffer
%   idx  - can also get the char values: 'next','last','all'
%   bysch  - [0/1/2] 0 - idx are indexes into the TaskBuffer
%                    1 - idx are indexes into the TaskSchedule
%                    2 - idx are ids of Tasks from the Buffer
% 


% fill in default values
if ~exist('bysch','var')
    bysch=1;
end
    
% transform char into indexes
if ischar(idx)
    switch idx
        case 'next'
            idx=1;
        case 'last'
            idx=size(rS.TaskSchedule,1);
        case 'all' 
            if bysch==1
                idx=1:size(rS.TaskSchedule,1);
            else
                idx=1:numel(rS.TaskBuffer);
            end
        otherwise
    end
end

switch bysch
    case 0 % index are directly to TaskBuffer
        indx=idx;
    case 1 %index is for schedule
        %validate input
        if isempty(rS.TaskSchedule) || max(idx) > size(rS.TaskSchedule,1)
            error('Task requested is outside of current schedule, please update schedule and try again');
        end
        % find the shared ids between buffer and schedule
        ids=rS.TaskSchedule(idx,1);
        bfrids=get(rS.TaskBuffer,'id');
        bfrids=[bfrids{:}]';
        [both_ids,indx]=intersect(bfrids,ids);
    case 2 %idx are actually ids not indexes
        bfrids=get(rS.TaskBuffer,'id');
        bfrids=[bfrids{:}]';
        [both_ids,indx]=intersect(bfrids,idx);
    otherwise 
   
end
% check for ids and get them 

Tsks=rS.TaskBuffer(indx);





