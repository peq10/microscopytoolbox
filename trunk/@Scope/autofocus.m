function F=autofocus(rS,mthd)
% rS autofocus method, utilizes several strategies:
% 'coarse'    -
% 'coarse2'   -
% 'fine'      -
% 'dual-step' - 
%
% Function outline: 
% 1. based on mthd determine the appropriate commads for the stage
% 2. send commands for the stage
% 3. wait 
% 4. get focus score if needed

if ~exist('mthd','var'), mthd='corase'; end

switch mthd
    case 'corase'
        cmdStg='AFSET X=50 Y=2000';
        fcsDo='AF x=5';
    case 'corase2'
        fcsSetting='AFSET X=10 Y=1000';
        fcsDo='AF x=5';
    case 'fine'
        fcsSetting='AFSET X=1 Y=400';
        fcsDo='AF x=6';
    case 'dualstep'
        fcsSetting='AFSET X=50 Y=2000';
        fcsDo='AF x=5';
end

%% send the AF commands to the stage
cmdStg(rS,fcsSetting);
cmdStg(rS,fcsDo);


%% wait for the autofocus to end
n=0;
while get(rS,'stageBusy')
    pasue(0.2)
    if n>100, 
        warning('Stoped waiting for stage, something is taking to long...');
        break
    end
end


%% 4 return the current focus score if needed
if nargout>0
    F=get(rS,'FcsScr');
end


