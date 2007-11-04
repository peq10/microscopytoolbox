function acq_spindleHunt(Tsk) 

global rS;

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
Zguess.QdataType='FocalPlaneGuess';
Zguess.Value=0;
Zguess.QdataDescription='';

qdata=[Zguess];

Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'qdata',qdata);
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% show image in figure 3
figure(3)
imshow(img(:,:,1),[],'initialmagnification','fit')

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% Write image to disk
writeTiff(Tsk,img,get(rS,'rootfolder')); 

%% show image
% showImg(Tsk,img(:,:,1),2)
