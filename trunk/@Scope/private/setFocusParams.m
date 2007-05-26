function setFocusParams(rSin,argin,param)
%GETFOCUSPARAMS a private method that isolates the call for focus related
%properties. 

% this trick make sure rS is updated without ading it to the output arguments. 
% notice that rSin MUST be the same global rS object. 
global rS;
rS = rSin;

switch lower(argin)
    case 'focusrange'
        cmdStg(rS,'setfocusrange',param); % Assuming param is in micron
    case 'focusspeed'
        cmdStg(rS,'setfocusspeed',param);
    case 'focushilldetectheight'
        cmdStg(rS,'setfocushillheight',param);
    case 'focussearchdirection'
        switch param
            case 'UP'
                fcstype=2;
            case 'DOWN'
                fcstype=4;
            case 'SPLIT'
                fcstype=6;
        end
        if get(rS,'focususehilldetect')
                fcstype=fcstype+6;
        end
        crntrng=get(rS,'focusrange');
        set(rS,'focusrange',0);
        cmdStg(rS,'autofocus',fcstype);
        set(rS,'focusrange',crntrng);
    case 'focususehilldetect'
        switch get(rS,'focussearchdirection')
             case 'UP'
                fcstype=2;
            case 'DOWN'
                fcstype=4;
            case 'SPLIT'
                fcstype=6;
        end
        if param
                fcstype=fcstype+6;
        end
        crntrng=get(rS,'focusrange');
        set(rS,'focusrange',0);
        cmdStg('autofocus',fcstype);
        set(rS,'focusrange',crntrng);
    otherwise
        warning('Focus Property does not exist or cannot be chagned'); %#ok
end

rS.focusParams=[];
get(rS,'focusRange'); 
