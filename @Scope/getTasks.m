function [Tsks,indx] = getTasks( rS,property,value )
% getTasks : retrives Tasks from rS that have specfic value for each property
% if property is an cell array, than value must be a cell array as well and
% in that case the returned Tasks are ones that have ALL the propery value
% pairs.
% 
% Note: Value are only allowed to be scalars (either char of numeric)
% others will be ignored
%
% two special cases are the 'all' and 'next', all returns them all, and next
% return the next task from the scheduer
%
% examples:
%          [Tsk,id]=getTasks(rS,'status','executed')
%          [Tsk,id]=getTasks(rS,{'status','fncstr'},{'executed','acq_simple'})

% check if its empty
if isempty(rS.TaskBuffer)
    Tsks=[]; 
    indx=[];
    return
end

% deal with special cases
if ischar(property) && strcmp(property,'all')
    Tsks=rS.TaskBuffer;
    indx=1:length(rS.TaskBuffer);
    return
end

if ischar(property) && strcmp(property,'next')
    id=rS.TaskSchedule(1);
    if isempty(id)
        Tsks=[];
        indx=[];
        return
    end
    [Tsks,indx]=getTasks(rS,'id',id);
    return
end

% if only single property supplied - make it a cell
if ~iscell(property) 
    property={property};
    value={value};
end

% find indexes that are true for all property value pairs
rtrns=true(length(rS.TaskBuffer),1);

for i=1:length(property)
    v=get(rS.TaskBuffer,property{i});
    if isa(value{i},'numeric')
        v=[v{:}]';
    end
    rtrns=rtrns & ismember(v,value{i});
end


indx=find(rtrns);

Tsks=rS.TaskBuffer(indx);





