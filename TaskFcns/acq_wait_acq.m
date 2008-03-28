function Tsk=acq_wait_acq(Tsk) 

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[Exposure,Channels,UserData]=get(Tsk,'exposuretime',...
                                     'Channels',...
                                      'UserData');
secToWait=UserData.secToWait;

%% get data from inital analysis
img(:,:,1)=UserData.spawnAnalysisXtraData.img;

%% wait
pause(secToWait)

%% snap another images
img(:,:,2)=acqImg(rS,Channels,Exposure);

%% check if spawning is needed
if get(Tsk,'spawn_flag')
    spawned=spawn(Tsk,img);
    if spawned, disp('spawned a task'); end
    Tsk=set(Tsk,'spawn_happened',spawned);
end

%% Write to disk
if get(Tsk,'writeImageToFile')
    writeTiff(Tsk,img,get(rS,'rootfolder'));
end

%% plot 
if get(Tsk,'plotDuringTask')
    plotAll(rS);
end



