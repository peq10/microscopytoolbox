function Tsk=acq_lookForProphaseCells(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels,UserData]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'UserData');
                                      
%% goto XYZ
set(rS,'xy',[X Y]); 

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
        warning('I lost focus totally - dont know why - moving on'); %#ok
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
imshow(img(:,:,1),[],'initialmagnification','fit')
figure(4)
plotTaskStatus(rS)
plotFocalPlaneGrid(rS,2);
plotRoute(rS,1)


%% check for prophase cells
PlausiblyProphase=funcClicker(img,3);

qdata.QdataType='Plausibly Prophase';
qdata.QdataDescription='';
qdata.Value=PlausiblyProphase;
Tsk=set(Tsk,'qdata',qdata);

%% if Plausible Prophase exist - start new tasks
if ~isempty(PlausiblyProphase)
    LookForNEBTsk=set(Tsk,'fcn','acq_lookForNEB','planetime',UserData.NEB.T);
    addTasks(rS,split(LookForNEBTsk));
end

%%
writeTiff(Tsk,img,get(rS,'rootfolder')); 
