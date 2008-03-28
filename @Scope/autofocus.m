function [inFocus,bestZ,allZ,allScrs]=autofocus(rSin,updateFocalPlaneGridFlag)
% rS autofocus based on rS currnet properties
% main thing is the focusmethod

% to use the global rS
global rS;
rS=rSin;

% set autoshuuter to false
% set(rS,'autoshutter',false)

% get the current focus method as a function handle
f=str2func(get(rS,'focusmethod'));

% autofocus
initZ=get(rS,'z');
[inFocus,bestZ,allZ,allScrs]=f(rS);
% only if autofocus function reports success, update the Z
% otherwise fall back to original
if inFocus
    set(rS,'z',bestZ)
else
    disp('didn''t find focus - return to original potision');
    set(rS,'z',initZ)
end

% return shutter to image-like behaviour
% set(rS,'channel','close')
% set(rS,'autoshutter',true)

% update the focal plane grid if asked for. 
% If not asked for, updating is default behavior
if ~exist('updateFocalPlaneGridFlag','var')
    updateFocalPlaneGridFlag=1;
end

if updateFocalPlaneGridFlag
    addFocusPoints(rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now); 
end
    