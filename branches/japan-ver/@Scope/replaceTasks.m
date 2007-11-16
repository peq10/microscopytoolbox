function replaceTasks( rSin,Tsks )
%REPLACETASKS of rS with Tsks - they must have existing ids. 
%   Detailed explanation goes here

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