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
        warning('I lost focus totally - dont know why - moving on');
        return
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

%% add a counter for number of tasks
OldTsk=getTasks(rS,'all',0);
cnt=0;
for i=1:length(OldTsk)
    if get(OldTsk(i),'executed') && ~isempty(get(OldTsk(i),'UserData'))
        cnt=cnt+1; 
    end
end

set(3,'name',['already clicked on: ' num2str(cnt) ' prophase cells']);

%% Ask if there are spindles here
figure(3)
[x,y,b]=ginput;
if sum(b==27)
    removeTasks(rS,'nontimed_nonexecuted');
    return
end

Prophase.QdataType='Prophase position';
Prophase.QdataDescription='';
if ~isempty(x)
    [prophase(1),prophase(2)]=get(rS,'x','y');
    prophase(3)=now;
    Tsk=set(Tsk,'UserData',prophase);
    Prophase.Value=[x y];% x y are the coordinate within the image
else
    Prophase.Value=[];
end
qdata=Prophase;
Tsk=set(Tsk,'qdata',qdata);

writeTiff(Tsk,img,get(rS,'rootfolder')); 

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));