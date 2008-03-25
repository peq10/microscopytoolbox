function autofocus(rSin,updateFocalPlaneGridFlag)
% rS autofocus based on rS currnet properties
% main thing is the focusmethod

% to use the global rS
global rS;
rS=rSin;

% get the current focus method as a function handle
f=str2func(get(rS,'focusmethod'));

% autofocus
f(rS);

% update the focal plane grid if asked for. 
% If not asked for, updating is default behavior
if ~exist('updateFocalPlaneGridFlag','var')
    updateFocalPlaneGridFlag=1;
end

if updateFocalPlaneGridFlag
    addFocusPoints(rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now); 
end
    