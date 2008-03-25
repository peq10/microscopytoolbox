function waitFor(rS,dv)
% waitFor : pauses and waits for devices to stop being busy
%   currently only supports the stage but could easily add more device. 
%
%   example: 
%           waitFor(rS,'stage');

switch dv
    case 'stage'
        fprintf('waiting for stage');
        while get(rS,'stageBusy')
            fprintf('.')
            pause(0.1)
        end
        fprintf('done\n');
    otherwise
        fprintf('don''t know what to wait for...');
end