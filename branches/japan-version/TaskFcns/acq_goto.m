function acq_goto(Tsk) 
%goto move the stage to the Tsk x,y,z position
%   

global rS;

%% get the crnt acq details 
[X,Y]=get(Tsk,'stageX','stageY');

%% goto XY
set(rS,'xy',[X Y]);
waitFor(rS,'stage');

%% update status figures
figure(1)
tb=getTasks(rS,'executed');
if ~isempty(tb)
    t=get(tb,'planetime');
    if iscell(t)
        t=[t{:}]';
    end
    [bla,ix]=max(t);
    [x,y]=get(tb(ix),'stagex','stagey');
    X=[x; X];
    Y=[y; Y];
end
plot(X,Y,'-or');

%% update the x,y in the metadata of rS
Tsk=set(Tsk,'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'planetime',now);

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% update Task Status
figure(4)
plotTaskStatus(rS)

