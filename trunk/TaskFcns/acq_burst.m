function Tsk=acq_burst(Tsk) 

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[Exposure,Channels,UserData]=get(Tsk,'exposuretime',...
                                     'Channels',...
                                     'UserData');
imgNumInBurst=UserData.imgNumInBurst;

%% snap images
for i=1:imgNumInBurst
    img(:,:,:,i)=acqImg(rS,Channels,Exposure);
    t(i)=now;
end

%% check if spawning is needed
if get(Tsk,'spawn_flag')
    spawned=spawn(Tsk,img);
    if spawned, disp('spawned a task'); end
    Tsk=set(Tsk,'spawn_happened',spawned);
end

%% update Task metadata - include info from burst
Tsk=set(Tsk,'acqTime',t,...
            'dimensionorder','XYCTZ',...
            'dimensionsize',[length(Channels) imgNumInBurst 1]);
TskByTimepoint=split(Tsk);
for i=1:imgNumInBurst
    TskByTimepoint(i)=updateMetaData(TskByTimepoint(i));
end
% concatination reduces the object to be a metadata
MD=concat(TskByTimepoint);

%% Write to disk
if get(Tsk,'writeImageToFile')
    writeTiff(MD,img,get(rS,'rootfolder'));
end

%% plot 
if get(Tsk,'plotDuringTask')
    plotAll(rS);
end



