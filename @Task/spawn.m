function spawned=spawn(Tsk,img)
% spawn  :  create new Tasks based on spawn datafileds and adds it to rS
%    This is all depends on the attributes of Task
%    see set/get and the attributes in the html doc for details. 

global rS;

[testFcn,tskFcn,attr2mod,fnAdd]=get(Tsk,'spawn_testfcn',...
                                        'spawn_tskfcn',...
                                        'spawn_attributes2modify',...
                                        'spawn_filenameaddition');
                                        
% chek to see if spawn is needed   
[toSpawn,xtraData]=testFcn(img);
if toSpawn
    % if so, inherit the attributes of current task
    NewTsk=Tsk;
    % change everything that's built-in (userdata, taskfcn,filename)
    userData=get(NewTsk,'userdata');
    userData.spawnAnalysisXtraData=xtraData;
    filename=[get(NewTsk,'filename') fnAdd];
    NewTsk=set(NewTsk,'filename',filename,...
                      'userData',userData,... 
                      'tskfcn',tskFcn,...
                      'spawn_flag',false);
                  
    % change attr as needed (allowing overwritting the built-ins)
    fld=fieldnames(attr2mod);
    for i=1:length(fld)
        if strcmpi(fld{i},'acqTime')
            attr2mod.(fld{i})=transformUnits(rS,'acqTime',attr2mod.(fld{i}));
        end
        NewTsk=set(NewTsk,fld{i},attr2mod.(fld{i}));
    end              
    if get(Tsk,'spawn_queue')              
        addTasks(rS,NewTsk);
    else
        do(NewTsk);
    end
    spawned=true;
else
    spawned=false;
end
