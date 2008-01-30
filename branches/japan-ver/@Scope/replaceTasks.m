function replaceTasks( rSin,Tsks )
%replateTasks : from the buffer with Tasks based on their id. 
%   This method extracts the ids from Tsks and replaces all the Tasks
%   in the buffer with the same ids.
%   this is mostly useful after the Tsk was performed and Data regarding
%   the Task has changed. 
% 
% example: 
%         replaceTasks(rS,Tsk);

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

ids=get(Tsks,'id');
if length(Tsks)>1
    ids=[ids{:}]';
end

[oldTsks,idx]=getTasks(rS,'id',ids);
rS.TaskBuffer(idx)=Tsks;