function acq_MechTurk(Tsk) 

global rS;

% check if there are already 10 prophase cells
% OldTsk=getTasks(rS,'executed');
% XY=get(OldTsk,'UserData');
% XY=[XY{:}]/2;
% if length(XY>=10)
%     return
% end

%% get the crnt acq details 
[X,Y,Exposure,Channels,Binning]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning');
% Z=guessFocalPlane(rS,X,Y);

%% goto XYZ
set(rS,'xy',[X Y],'binning',Binning);

%% wait for perfect focus
pause(0.5)
cnt=0;
while ~get(rS,'pfs')
    set(rS,'pfs',1)
    cnt=cnt+1;
    pause(0.5)
    if cnt>10
        error(' I lost focus totally - dont knopw why');
    end
end
%% update status figures
figure(1)
plot(X,Y,'-or');

%% update Tsk object so the value I write to disk are actual not theoretical
Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'));
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% show image in figure 3
figure(3)
imshow(img(:,:,1),[],'initialmagnification','fit')

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% Ask if there are spindles here
figure(3)
[x,y,b]=ginput(1);
Prophase.QdataType='Prophase position';
Prophase.QdataDescription='';
if b==3
    [prophase(1),prophase(2)]=get(rS,'x','y');
    Tsk=set(Tsk,'UserData',prophase);
    Prophase.Value=[x y];
else
    Prophase.Value=[NaN NaN];
end
qdata=Prophase;
Tsk=set(Tsk,'qdata',qdata);

writeTiff(Tsk,img,get(rS,'rootfolder')); 

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));
