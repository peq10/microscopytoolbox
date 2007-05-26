function removeTasks(rSin,idx)
%REMOVETASK Summary of this function goes here
%   Detailed explanation goes here

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

if ischar(idx) && strcmp(idx,'all')
    [bla,idx]=getTasks(rS,'all',0); 
end

% get the indexes of what about to stay. 
idx=setdiff(1:length(rS.TaskBuffer),idx);

rS.TaskBuffer=rS.TaskBuffer(idx); 