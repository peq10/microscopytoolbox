function acq_spindleHunt(Tsk) 

global rS;

%% get the crnt acq details 
[X,Y,Exposure,Channels,Z,UserData,T,Qdata]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'stageZ',...
                                          'UserData',...
                                          'planetime',...
                                          'Qdata');
ix=find(abs(UserData.T-T)*86400<0.1);
% ix is the index of Task in the original Task before the split

%% goto XYZ
set(rS,'xy',[X Y]);

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
Zguess.QdataType='FocalPlaneGuess';
Zguess.Value=0;
Zguess.QdataDescription='';

qdata=[Zguess];

Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'qdata',qdata);
        
%% acquire stack
set(rS,'PFS',0);
Tsk=set(Tsk,'DimensionOrder','XYCZT');
current_Z=get(rS,'z');
for i=1:length(Z)
    set(rS,'z',current_Z+Z(i));
    if UserData.ImgTubChannel(ix)
        img(:,:,:,i)=acqImg(rS,Channels,Exposure);
    else
        tmp=acqImg(rS,Channels(1),Exposure(1));
        img(:,:,:,i)=cat(3,tmp,zeros(size(tmp)));
    end
end
set(rS,'z',current_Z)
set(rS,'PFS',1);

%% show image in figure 3
figure(3)
if UserData.ImgTubChannel(ix)
    red=imadjust(max(img(:,:,1,:),[],4));
    green=imadjust(max(img(:,:,2,:),[],4));
else
    red=imadjust(max(img(:,:,1,:),[],4));
    green=zeros(size(red));
end

imshow(cat(3,red,green,zeros(size(red))),'initialmagnification','fit')

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% shift cell centers if needed
tileSize=256;
Qdata.Value(:,1)=max(ceil(Qdata.Value(:,1)),tileSize/2);
Qdata.Value(:,1)=min(floor(Qdata.Value(:,1)),size(img,2)-tileSize/2);
Qdata.Value(:,2)=max(ceil(Qdata.Value(:,2)),tileSize/2);
Qdata.Value(:,2)=min(floor(Qdata.Value(:,2)),size(img,1)-tileSize/2);

%% Write image to disk
for i=1:size(Qdata.Value,1)
    % crop
    indx=(Qdata.Value(:,1)-tileSize/2):(Qdata.Value(:,1)+tileSize/2);
    indy=(Qdata.Value(:,2)-tileSize/2):(Qdata.Value(:,2)+tileSize/2);
    imgcrp=img(indy,indx,:,:,:);
    % create a new Task with new filename
    old_filename=get(Tsk,'filename');
    TskTmp=set(Tsk,'filename',[old_filename '_' num2str(i)]);
    writeTiff(TskTmp,imgcrp,get(rS,'rootfolder'));
end
