function setFocusParams(rSin,focusMethod,ParamName,ParamValue)
%setFocusParam a method that add/sets a specific sub-propertiy, e.g. 
% In this version, all the focus parameters are kept in rS
% in the future (with matlab new OOP) focus would be a class not a function!
% therefore it would be much easier to handle all this "where to keep focus propertiues":
% thing...


% this trick make sure rS is updated without ading it to the output arguments. 
% notice that rSin MUST be the same global rS object. 
global rS;
rS = rSin;

% In this version, all the focus parameters are kept in rS
% in the future (with matlab new OOP) focus would be a class not a function!
% therefore it would be much easier to handle all this "where to keep focus propertiues":
% thing...
rS.focusParams.(focusMethod).(ParamName)=ParamValue;


