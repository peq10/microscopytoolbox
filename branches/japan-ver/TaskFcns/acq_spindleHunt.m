function acq_spindleHunt(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels,Binning]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning');
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

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% decide if I need to start a timelapse
dt=30;
[SpindlesFound,SpindlePoles]=funcDetectSpindle(img);
if SpindlesFound
    for i=1:2:size(SpindlePoles,1);
        UserData.cntr(ceil(i/2),:)=mean(SpindlePoles(i:i+1,1:2));
    end
    for i=1:10
        TimeLapseTsks(i)=set(Tsk,'planetime',now+i*dt/24/3600,...
                                 'tskfcn','acq_spindleTimeLapse',...
                                 'timedependent',true,...
                                 'UserData',UserData);
    end
    addTasks(rS,TimeLapseTsks);
    plotPlannedSchedule(rS,1)
end

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% Write image to disk
% writeTiff(Tsk,img,get(rS,'rootfolder')); 

%% show image
% showImg(Tsk,img(:,:,1),2)
