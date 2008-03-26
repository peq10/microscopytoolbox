function varargout = ASI(rS)
%ASI Summary of this function goes here
%   Detailed explanation goes here


% set channel to focusing channel
crnt_chnl=get(rS,'channel');
set(rS,'channel','white');

% this is a "hack" its ASI specific, need to change where there is a autofocus device
rS.mmc.setSerialPortCommand(rS.COM,'AF',char(13))
waitFor(rS,'stage')
set(rS,'channel',crnt_chnl);

if nargout
    varargout{1}=1;
end