function removeTasks(rSin,property,value)
% removeTasks:  removes tasks based on specific criteria
%    uses getTasks for task identification so similar syntax appleis
%    this means that the speical temrs ('all','next') are possible in
%    addition to the property value. 
%  
% example: 
%    removeTasks(rS,'all')
%    removeTasks(rS,'fncstr','acq_crazy')


% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

if ~exist('value','var') || isempty(value)
    value=0;
end

[bla,indx]=getTasks(rS,property,value);

% get the indexes of what about to stay. 
indx=setdiff(1:length(rS.TaskBuffer),indx);

rS.TaskBuffer=rS.TaskBuffer(indx); 