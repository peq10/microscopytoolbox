function Tsk=acq_timelapse(Tsk) 

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[X,Y,Exposure,Channels,UserData]=get(Tsk,'stageX',...
                                         'stageY',...
                                         'exposuretime',...
                                         'Channels',...
                                         'UserData');
T=UserData.T;
                                     
%% goto XYZ
set(rS,'xy',[X Y]);

%% autofocus 
autofocus(rS);

%% snap image
img=acqImg(rS,Channels,Exposure);

%% check if spawning is needed
if get(Tsk,'spawn_flag')
    spawned=spawn(Tsk,img);
    if spawned, disp('spawned a task'); end
    Tsk=set(Tsk,'spawn_happened',spawned);
end

%% update Task metadata
Tsk=updateMetaData(Tsk);

%% Write to disk
if get(Tsk,'writeImageToFile')
    writeTiff(Tsk,img,get(rS,'rootfolder'));
end

%% plot 
if get(Tsk,'plotDuringTask')
    plotAll(rS);
end



