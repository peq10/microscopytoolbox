function argout = getFocusParams(rSin,argin)
%GETFOCUSPARAMS a private method that isolates the call for focus related
%properties. 

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

% determine if rS has all these parameters
if isempty(rS.focusParams)
    % Query all parameters from the Stage.
    rS.mmc.setSerialPortCommand(rS.COM,'AF X?',char(13));
    %% matlab bug hack
    disp('querying stage...')
    pause(1) %otherwise matlab crashes, go figure...
    %% end of matlab bug hack
    str=rS.mmc.readFromSerialPort(rS.COM);
    for i=1:str.size, 
        params(i)=str.get(i-1);
    end
    while ~isempty(params)
        [fld,params]=strtok(params,char(13)); %#ok<STTOK>
        [fldname,val]=strtok(fld,':');
        val=str2double(regexprep(val,':',''));
        switch fldname(2:end)
            case 'current_type'
                arg.type=val;
            case 'X=fine_speed'
                arg.speed_fine=val;
            case 'X=coarse_speed'
                arg.speed_corase=val;
            case 'Y=travel fine'
                arg.range_fine=val*1000;
            case 'Y=travel coarse'
                arg.range_corase=val*1000;
            case 'F=hill_offset'
                arg.hill_offset=val;
        end
    end
    rS.focusParams=arg; 
end

%% get the params. 
params=rS.focusParams;

%% translate them to 'normal' values
switch lower(argin)
    case 'focusrange'
        argout=params.range_corase; % move from mm to microns
    case 'focusspeed'
        argout=params.speed_corase;
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
    case 'focustype'
        argout=params.type;
    case 'focusparams'
        argout=params;
end
