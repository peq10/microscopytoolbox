function autofocus(rSin,updateFocalPlaneGridFlag)
% rS autofocus based on rS currnet properties
%
% TODO: need a complete re-write based and move to using only MMC autofocus
% devices. 

% to use the global rS
global rS;
rS=rSin;

% set channel to focusing channel
crnt_chnl=get(rS,'channel');
set(rS,'channel','white');

% this is a "hack" its ASI specific, need to change where there is a autofocus device
rS.mmc.setSerialPortCommand(rS.COM,'AF',char(13))
waitFor(rS,'stage')
set(rS,'channel',crnt_chnl);

if ~exist('updateFocalPlaneGridFlag','var')
    updateFocalPlaneGridFlag=1;
end

if updateFocalPlaneGridFlag
    addFocusPoints(rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now); 
end
    