function taskIDs = getNewTaskIDs(rS,n)
%GETNEWTASKIDS returns n new task IDs
%   keep track of call from time to time; 


if nargin==1
    n=1;
end

% get the min /max new task IDs
mn=rS.taskID+1;
mx=rS.taskID+n;

% update the taskID property
rS.taskID=rs.taskID+n;

taskIDs=mn:mx;