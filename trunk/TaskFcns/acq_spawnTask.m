function Tsk=acq_spawnTask(Tsk) 
% image and maybe spawns a new task

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[X,Y,Exposure,Channels]=get(Tsk,'stageX',...
                                'stageY',...
                                'exposuretime',...
                                'Channels');

%% goto XYZ
set(rS,'xy',[X Y]);

%% snap image
img=acqImg(rS,Channels,Exposure);

%% decide if we want to spawn a new Task
userData=get(Tsk,'userdata');
checkFunction=userData.checkFunction;
attrToChange=userData.attrToChange;
filenameAddition=userData.filenameAddition;

if checkFunction(img)
    NewTsk=Tsk;
    fld=fieldnames(attrToChange);
    for i=1:length(fld)
        NewTsk=set(NewTsk,fld{i},attrToChange.(fld{i}));
    end
    NewTsk=set(NewTsk,'filename',[get(NewTsk,'filename') filenameAddition]);
    addTasks(rS,NewTsk);
    userData.spawned=true;
else
    userData.spawned=false;
end

%% update Task metadata 
% everything goes to default beside Z which is the realZ that was taken on
% the stack. 
Tsk=updateMetaData(Tsk,'userData',userData);

%% Write to disk
if get(Tsk,'writeImageToFile')
    writeTiff(Tsk,img,get(rS,'rootfolder'));
end

%% plot 
if get(Tsk,'plotDuringTask')
    plotAll(rS);
end



