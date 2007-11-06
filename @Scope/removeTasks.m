function removeTasks(rSin,idx)
%REMOVETASK Summary of this function goes here
%   Detailed explanation goes here

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

if ischar(idx) 
    switch idx
        case 'all'
             [bla,idx]=getTasks(rS,'all',0); 
        case 'executed'
            [bla,idx]=getTasks(rS,'executed',0); 
        case 'nontimed'
            [bla,idx]=getTasks(rS,'nontimed',0); 
        case 'timed'
            [bla,idx]=getTasks(rS,'timed',0); 
        case 'nontimed_nonexecuted'
            [bla,nontimed]=getTasks(rS,'nontimed',0); 
            [bla,executed]=getTasks(rS,'executed',0); 
            nonexecuted=setdiff(1:length(rS.TaskBuffer),executed);
            idx=intersect(nonexecuted,nontimed);
        otherwise
            error('UnsupportedÅ@remove syntax')
    end
end

% get the indexes of what about to stay. 
idx=setdiff(1:length(rS.TaskBuffer),idx);

rS.TaskBuffer=rS.TaskBuffer(idx); 