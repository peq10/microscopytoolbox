function acq_goto(Tsk) 
%goto move the stage to the Tsk x,y,z position
%   

global rS;

%% get the crnt acq details 
[X,Y]=get(Tsk,'X','Y');

%% goto XY
set(rS,'xy',[X Y]);
waitFor(rS,'stage');

%% update the x,y in the metadata of rS
md=get(Tsk,'metadata');
md=set(md,'stage.x',get(rS,'x'),'stage.y',get(rS,'y'));
Tsk=set(Tsk,'executed',true,'MetaData',md);

replaceTasks(rS,Tsk);

