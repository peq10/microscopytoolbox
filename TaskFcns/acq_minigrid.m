function Tsk=acq_minigrid(Tsk) 

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[Xcntr,Ycntr,Exposure,Channels,UserData]=get(Tsk,'stageX',...
                                         'stageY',...
                                         'exposuretime',...
                                         'Channels',...
                                         'UserData');

dX=UserData.dX;
MiniGridSize=UserData.MiniGridSize;
[X,Y]=meshgrid(Xcntr+(-dX:dX:dX),Ycntr+(-dX:dX:dX));
 
%% autofocus 
autofocus(rS);

%% goto all XY once
for i=1:numel(X)
    set(rS,'xy',[X(i) Y(i)]);
    %% snap image
    img(:,:,:,i)=acqImg(rS,Channels,Exposure);
    i
end

%% Start a second round of imaging, in this round, check for 
%  spawning 
for i=1:numel(X)
    set(rS,'xy',[X(i) Y(i)]);
    %% snap image
    img2(:,:,:,i)=acqImg(rS,Channels,Exposure);
    %% check if spawning is needed
    if get(Tsk,'spawn_flag')
        img_two_timepoints=cat(4,img(:,:,:,i),img2(:,:,:,i));
        spawned=spawn(Tsk,img_two_timepoints);
        if spawned, disp('spawned a task'); end
        Tsk=set(Tsk,'spawn_happened',spawned);
    end
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



