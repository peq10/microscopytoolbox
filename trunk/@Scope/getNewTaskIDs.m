function taskIDs = getNewTaskIDs(rSin,n)
%GETNEWTASKIDS returns n new task IDs
%   keep track of call from time to time; 

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

if nargin==1
    n=1;
end

% get the min /max new task IDs
mn=rS.taskID+1;
mx=rS.taskID+n;

% update the taskID property
rS.taskID=rS.taskID+n;

taskIDs=mn:mx;