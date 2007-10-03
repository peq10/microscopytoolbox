function [Tsks,indx] = getTasks( rS,idx,bysch )
%GETTASKS from rS. idx numerical index of task by oder (1=first end=last).
%   indx is the location of the task in the TaskBuffer
%   idx  - can also get the char values: 'next','last','all'
%   bysch  - [0/1/2] 0 - idx are indexes into the TaskBuffer
%                    1 - idx are indexes into the TaskSchedule
%                    2 - idx are indexes into the TimedTaskSchedule
%                    3 - idx are ids of Tasks from the Buffer
% 


% fill in default values
if ~exist('bysch','var')
    bysch=1;
end
    
% transform char into indexes
if ischar(idx)
    switch idx
        case 'timed'
            tm=get(rS.TaskBuffer,'timedependent');
            tm=[tm{:}]';
            idx=find(tm);
            bysch=0;
        case 'nontimed'
            tm=get(rS.TaskBuffer,'timedependent');
            tm=[tm{:}]';
            idx=find(tm==0);
            bysch=0;
        case 'next'
            switch lower(get(rS,'schedulingmethod'))
                case 'ants_tsp'
                    idx=1;
                case 'manual'
                    idx=1;
                case 'greedy'
                    PossibleTsks=getTasks(rS,rS.TaskSchedule,3);
                    tm=get(PossibleTsks,'timedependent');
                    if iscell(tm)
                        tm=[tm{:}]';
                    end
                    idx_timed=find(tm); %#ok<EFIND>
                    [x,y]=get(PossibleTsks,'stagex','stagey');
                    if iscell(x), x=[x{:}]; end
                    if iscell(y), y=[y{:}]; end
                    xy=[x; y];
                    [crntpos(1),crntpos(2)]=get(rS,'x','y');
                    crntpos=crntpos(:);
                    D=distance(xy,crntpos);
                    [bla,idx]=min(D);
                    if ~isempty(idx_timed)
                        % find out the time to next timed task
                        tsktime=get(PossibleTsks,'planetime');
                        if iscell(tsktime), tsktime=[tsktime{:}]; end
                        [nexttsktime,idx_timed]=min(tsktime,[],2);
                        % check to see if there are multiple tasks that are the closets
                        % and if so change the idx_timed to be the closet one
%                         same_time_ix=find(tsktime==nexttsktime);
%                         if length(same_time_ix) > 1
%                             [x,y]=get(PossibleTsks(same_time_ix),'stagex','stagey');
%                             xy=[[x{:}]; [y{:}]];
%                             D=distance(xy,crntpos);
%                             [bla,idx]=min(D);
%                             idx_timed=same_time_ix(idx);
%                         end
                        [xy_timed(1),xy_timed(2)]=get(PossibleTsks(idx_timed),'stagex','stagey');
                        if nexttsktime-now < get(PossibleTsks(idx),'runtime')+ ...
                                             calcMoveTime(rS,xy_timed) + ...
                                             calcMoveTime(rS,xy_timed,xy)
                           idx=idx_timed; 
                        end
                        indx=idx;
                        Tsks=PossibleTsks(idx);
                        return
                    end
                otherwise
                    error('If you added another schedulaing method - update the code...');
            end
        case 'last'
            idx=size(rS.TaskSchedule,1);
        case 'all' 
            if bysch==1
                idx=1:size(rS.TaskSchedule,1);
            else
                bysch=0;
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
        ids=rS.TaskSchedule(idx);
        bfrids=get(rS.TaskBuffer,'id');
        bfrids=[bfrids{:}]';
        [both_ids,indx]=intersect(bfrids,ids);
    case 2
        %validate input
        if isempty(rS.TimedTaskSchedule) || max(idx) > size(rS.TimeTaskSchedule,1)
            error('Task requested is outside of current Timed schedule, please update schedule and try again');
        end
        % find the shared ids between buffer and schedule
        ids=rS.TimedTaskSchedule(idx,1);
        bfrids=get(rS.TaskBuffer,'id');
        bfrids=[bfrids{:}]';
        [both_ids,indx]=intersect(bfrids,ids);
    case 3 %idx are actually ids not indexes
        bfrids=get(rS.TaskBuffer,'id');
        bfrids=[bfrids{:}]';
        [both_ids,indx]=intersect(bfrids,idx);
    otherwise 
   
end
% check for ids and get them 

Tsks=rS.TaskBuffer(indx);





