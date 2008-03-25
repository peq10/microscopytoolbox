function varargout=pfs(rSin)
% a autofocus function that
% make sure we're using the global rS
global rS;
rS=rSin;

% get the focus parameters
FocusParam=get(rS,'focusParams');

% here we'll put the implementation of justPint
inFocusFlag=1;

% return success flag is asked for
if nargout
    varargout{1}=inFocusFlag;
end