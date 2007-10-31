function ordr = greedy(x,y,t,id,xcurrent,ycurrent,tasks_duration,tcurrent)
%GREEDY - a type of scheduler that is , well greedy...

% min time for task

ordr=[];
ix=find(isnan(t));
if isempty(ix) % this mean they are all timed
    [tsrt,ix]=sort(t);
    ordr=id(ix);
    return;
end
non_timed=[x(ix) y(ix) t(ix) id(ix) tasks_duration(ix)];
ix=find(~isnan(t));
timed=[x(ix) y(ix) t(ix) id(ix) tasks_duration(ix)];

for i=1:length(x)
    % find time till next timed task
    [time_to_next,next_by_time_ix]=min(timed(:,3));
    % find who is the closet task time it will take to do a non-timed task
    D=distance(non_timed(:,1:2)',[xcurrent; ycurrent]);
    [bla,next_non_timed_ix]=min(D);
    
    % If there is no more timed tasks - add a non timed one
    if isempty(next_by_time_ix) 
        % add next by position
        ordr=[ordr; non_timed(next_non_timed_ix,4)];
        tcurrent=tcurrent+non_timed(next_non_timed_ix,5);
        xcurrent=non_timed(next_non_timed_ix,1);
        ycurrent=non_timed(next_non_timed_ix,2);
        non_timed=non_timed(setdiff(1:size(non_timed,1),next_non_timed_ix),:);
        continue
    end
    
    % If there is no more non-timed tasked add the next timed one
    if isempty(next_non_timed_ix)
        % add next by time
        ordr=[ordr; timed(next_by_time_ix,4)];
        tcurrent=tcurrent+timed(next_by_time_ix,5);
        xcurrent=timed(next_by_time_ix,1);
        ycurrent=timed(next_by_time_ix,2);
        timed=timed(setdiff(1:size(timed,1),next_by_time_ix),:);
        continue
    end
    
    % If both exist - choose based on time to next timed task and duration of
    % closet non-timed task
    if non_timed(next_non_timed_ix,5)<(time_to_next-tcurrent)
        ordr=[ordr; non_timed(next_non_timed_ix,4)];
        tcurrent=tcurrent+non_timed(next_non_timed_ix,5);
        xcurrent=non_timed(next_non_timed_ix,1);
        ycurrent=non_timed(next_non_timed_ix,2);
        non_timed=non_timed(setdiff(1:size(non_timed,1),next_non_timed_ix),:);
    else
        ordr=[ordr; timed(next_by_time_ix,4)];
        tcurrent=tcurrent+timed(next_by_time_ix,5);
        xcurrent=timed(next_by_time_ix,1);
        ycurrent=timed(next_by_time_ix,2);
        timed=timed(setdiff(1:size(timed,1),next_by_time_ix),:);
    end
end