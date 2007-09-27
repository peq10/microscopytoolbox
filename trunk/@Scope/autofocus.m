function autofocus(rS,mthd)
% rS autofocus based on rS currnet properties

% set channel to focusing channel
crnt_chnl=get(rS,'channel');
set(rS,'channel','white');

% this is a "hack" its ASI specific, need to change where there is a autofocus device
rS.mmc.setSerialPortCommand(rS.COM,'AF',char(13))
waitFor(rS,'stage')
set(rS,'channel',crnt_chnl);

