function varargout=noAutoFocus(rSin)
% a autofocus function that does nothing
% make sure we're using the global rS
global rS;
rS=rSin;

% get the focus parameters
FocusParam=get(rS,'focusParams');

% by defenition in the no AutoFocus methods we are always not in focus
% since we don't know if we are in focus or not. 
inFocusFlag=0;

% return success flag is asked for
if nargout
    varargout{1}=inFocusFlag;
end