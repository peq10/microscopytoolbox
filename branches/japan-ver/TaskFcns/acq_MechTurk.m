function Tsk=acq_MechTurk(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames');
                                      
Z=guessFocalPlane(rS,X,Y);
%% goto XYZ
set(rS,'xy',[X Y],'Z',Z);

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

%% update status figures
plotRoute(rS,1)

%% update Tsk object so the value I write to disk are actual not theoretical
Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'));
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% show image in figure 3
figure(3)
clf
subplot('position',[0 0 1 1])
imshow(img(:,:,1),[],'initialmagnification','fit')

%% update Task Status
figure(4)
plotTaskStatusByType(rS)

%% add a counter for number of tasks
OldTsk=getTasks(rS,'all',0);
cnt=0;
for i=1:length(OldTsk)
    if strcmp(get(OldTsk(i),'status'),'executed') && ~isempty(get(OldTsk(i),'UserData'))
        cnt=cnt+1; 
    end
end

set(3,'name',['already clicked on: ' num2str(cnt) ' prophase cells']);

%% Ask if there are spindles here
figure(3)
[x,y,b]=ginput;
% x=650;?¿½@y=514;?¿½@b=1; % used for silly acquisition..

if sum(b==27)
    removeTasks(rS,{'timedependent','status'},{false,'inqueue'});
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
