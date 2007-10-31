function waitFor(rS,dv)
%WAITFOR Summary of this function goes here
%   Detailed explanation goes here

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