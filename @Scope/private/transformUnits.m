function outpt = transformUnits( rS, typ, inpt )
% transformUnits : a private method that transforms units based on what rS
% is currently defined to. It transform all stage related stuff into
% micro-meter, exposure time into ms and acqTime into days (thats how
% matlab lieks it...)
%
% Note: for acqTime, it also checks to see if maybe the user forgot to
% supply the value in absolute time and not relative time. If the time
% asked is in the previous century, assume its a user mistake and correct
% it. 

% if its a cell array, act on each element in the array
if iscell(inpt)
    for i=1:length(inpt)
        outpt{i}=transformUnits( rS, typ, inpt{i} );
    end
    return
end

% inpt must be numeric array
if ~isnumeric(inpt)
    error('unit transformation attempted with wrong input values');
end

%% perform the transformation

switch lower(typ)
    case 'stagexy'
        switch rS.units.stageXY
            case 'mili-meter'
                outpt=inpt*1000;
            case 'micro-meter'
                outpt=input;
            case 'nano-meter'
                outpt=inpt/1000;
        end
    case 'stagez'
        switch rS.units.stageZ
            case 'mili-meter'
                outpt=inpt*1000;
            case 'micro-meter'
                outpt=input;
            case 'nano-meter'
                outpt=inpt/1000;
        end
    case 'exposuretime'
        switch rS.exposureTime
            case 'msec'
                outpt=inpt;
            case 'sec'
                outpt=inpt*1000;
            case 'min' 
                outpt=inpt*1000*60;
            case 'hours'
                outpt=inpt*1000*60*60;
        end
    case 'acqtime'
        switch rS.acqTime
            case 'msec'
                outpt=inpt/24/60/60/1000;
            case 'sec'
                outpt=inpt/24/60/60;
            case 'min' 
                outpt=inpt/24/60;
            case 'hours'
                outpt=inpt/24;
        end
        % if acqTime is to small, we assume that the user actually 
        % wanted to do now+t
        if outpt < datenum('1-1-2000')
            outpt=outpt+now;
        end
end
            

            