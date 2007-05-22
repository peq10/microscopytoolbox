function argout = getFocusParams(rS,argin)
%GETFOCUSPARAMS a private method that isolates the call for focus related
%properties. 

% Query all parameters from the Stage. 
[ok,params]=cmdStg(rS,'getfocusparam');

if ~ok
    error('Could not communicate with the stage to query focus params');
end

switch lower(argin)
    case 'focusrange'
        argout=params.range_fine; % move from mm to microns
    case 'focusspeed'
        argout=params.speed_fine;
    case 'focussearchdirection'
        switch params.type
            case {1,2,7,8}
                argout='UP';
            case {3,4,9,10}
                argout='DOWN';
            case {5,6,11,12}
                argout='SPLIT';
        end
    case 'focususehilldetect'
        if params.type<7
            argout=0;
        else
            argout=1;
        end
    case 'focushilldetectheight'
        argout=params.hill_offset; 
    case 'focusscore'
        [ok,argout]=cmdStg(rS,'fcsscr');
    case 'focustime'
        argout=1; %TODO do proper calculation of how long focus will take based on range, speed and hill
end