function acq_spindleTimeLapse(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels,Binning,UserData]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning',...
                                          'UserData');
Z=guessFocalPlane(rS,X,Y);

%% goto XYZ
set(rS,'xy',[X Y],'z',Z,'binning',Binning);

%% update status figures
figure(1)
plot(X,Y,'-or');
figure(2)
plotFocalPlaneGrid(rS);

%% autofocus
autofocus(rS,1);
z=get(rS,'z');
z=z+get(Tsk,'zshift');
set(rS,'z',z);

%% update Tsk object so the value I write to disk are actual not theoretical
FcsScr.QdataType='FocusScore';
FcsScr.Value=get(rS,'focusscore');
FcsScr.QdataDescription='';

Zguess.QdataType='FocalPlaneGuess';
Zguess.Value=Z;
Zguess.QdataDescription='';

qdata=[FcsScr Zguess];

Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'qdata',qdata);
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% show image in figure 3
figure(3)
imshow(img,[],'initialmagnification','fit')
hold on
for i=1:size(UserData.cntr,1)
    rect=UserData.cntr(i,:)-50;
    plot([rect(2) rect(2)+100],[rect(1) rect(1)],'-','linewidth',3);
    plot([rect(2) rect(2)+100],[rect(1)+100 rect(1)+100],'-','linewidth',3);
    plot([rect(2) rect(2)],[rect(1) rect(1)+100],'-','linewidth',3);
    plot([rect(2)+100 rect(2)+100],[rect(1) rect(1)+100],'-','linewidth',3);
end

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% Write image to disk
writeTiff(Tsk,img,get(rS,'rootfolder')); 
