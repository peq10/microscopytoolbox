function Tsk=acq_lookForNEB(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels,UserData]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'UserData');
                                      
%% goto XYZ
set(rS,'xy-slow',[X Y]); 

%% implement focalPointGuess
% Zguess=guessFocalPlane(rS,X,Y);
% set(rS,'Z',Zguess);

%% wait for perfect focus
pause(0.5)
cnt=0;
while ~get(rS,'pfs')
    set(rS,'pfs',1)
    cnt=cnt+1;
    pause(0.5)
    if cnt>10
        fprintf('\nI lost focus totally - moving on\n'); %#ok
        return
    end
end

addFocusPoints(rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now); 

%% update Tsk object so the value I write to disk are actual not theoretical
Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'));
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% update plots
figure(3)
subplot('position',[0 0 1 1])
imshow(img(:,:,1),[],'initialmagnification','fit')
figure(4)
plotTaskStatusByType(rS)
plotFocalPlaneGrid(rS,2);
plotRoute(rS,1)
plotPastTaskDuration(rS,5)

%% check for NEB
qdata=get(Tsk,'qdata');
PlausiblyProphase=qdata.Value;
NEB=detectNEB(img,PlausiblyProphase,3);

% PlausiblyProphase.Time=now;
% PlausiblyProphase.NEB=NEB;

% qdata.QdataType='Plausibly Prophase With NEB data';
% qdata.QdataDescription='';
% qdata.Value=PlausiblyProphase;
% Tsk=set(Tsk,'qdata',qdata);

%% if NEB happened acquire a Z-stack and start a 5D timelapse
if sum(NEB)
    % remove all future tasks with my filename
    AllNonExecTsks=getTasks(rS,{'status','filename'},{'nonexecuted',get(Tsk,'filename')});
    for i=1:length(AllNonExecTsks)
        AllNonExecTsks(i)=set(AllNonExecTsks(ix(i)),'status','skipped'); %#ok<FNDSB>
    end
    replaceTasks(rS,AllNonExecTsks(ix));
    ZstkTsk=set(Tsk,'tskfcn','acq_Zstk_fully_automated','planetime',now+UserData.Zstack.T,...
                              'channels',UserData.Zstack.Channels,'exposuretime',UserData.Zstack.Exposure,...
                              'stageZ',UserData.Zstack.Zstack,'filename',[get(Tsk,'filename') '_Stk']);
    do(ZstkTsk);
    TimeLapseTsk=set(Tsk,'tskfcn','acq_5D_fully_automated','planetime',now+UserData.TimeLapse.T,...
                                       'channels',UserData.TimeLapse.Channels,'exposuretime',UserData.TimeLapse.Exposure,...
                                       'stageZ',UserData.TimeLapse.Zstack,'filename',[get(Tsk,'filename') '_5D']);
    addTasks(rS,split(TimeLapseTsk));
end

%%
writeTiff(Tsk,img,get(rS,'rootfolder')); 
