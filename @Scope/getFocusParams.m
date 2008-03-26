function argout = getFocusParams(rS,focusMethod,ParamName)

try
    argout=rS.focusParams.(focusMethod).(ParamName);
catch
    warning('Focus parameters doesn''t exist for this method');
end