function Tsk=acq_Zstk(Tsk) 

global rS;

tileSize=256;

%% get the crnt acq details 
[X,Y,Exposure,Channels,Z,Qdata]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'stageZ',...
                                          'Qdata');
Zguess=guessFocalPlane(rS,X,Y);
%% goto XYZ
% set(rS,'pfs',0)
% set(rS,'xy-slow',[X Y],'Z',Zguess);
set(rS,'xy-slow',[X Y])
%pause(1.5)

%% wait for perfect focus
set(rS,'pfs',1)
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

addFocusPoints(rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now); 

%% update status figures
plotRoute(rS,1)

%% update Tsk object so the value I write to disk are actual not theoretical
ZguessQdata.QdataType='FocalPlaneGuess';
ZguessQdata.Value=Zguess;
ZguessQdata.QdataDescription='';

qdata=ZguessQdata;

Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'qdata',qdata);

%% get the crop rectangles        
% shift cell centers if needed
imgsz=[get(rS,'Height') get(rS,'Width')]./get(rS,'Binning');
Qdata.Value(:,1)=max(ceil(Qdata.Value(:,1)),tileSize/2+1);
Qdata.Value(:,1)=min(floor(Qdata.Value(:,1)),imgsz(2)-tileSize/2);
Qdata.Value(:,2)=max(ceil(Qdata.Value(:,2)),tileSize/2+1);
Qdata.Value(:,2)=min(floor(Qdata.Value(:,2)),imgsz(1)-tileSize/2);
        
%% acquire stack
set(rS,'PFS',0);
Tsk=set(Tsk,'DimensionOrder','XYZCT');
current_Z=get(rS,'z');
imgcrp=cell(size(Qdata.Value,1));
mdl=ceil(length(Z)/2);
for c=1:length(Channels)
    for i=1:length(Z)
        set(rS,'z',current_Z+Z(i));
        img=acqImg(rS,Channels(c),Exposure(c)); %#ok<AGROW>
        for j=1:size(Qdata.Value,1)
            indx=(Qdata.Value(j,1)-tileSize/2):(Qdata.Value(j,1)+tileSize/2);
            indy=(Qdata.Value(j,2)-tileSize/2):(Qdata.Value(j,2)+tileSize/2);
            imgcrp{j}(:,:,c,i)=img(indy,indx);
        end
        if i==mdl, imgmdl(:,:,c)=img; end %#ok<AGROW>
    end
end

imgmdl=cat(3,imgmdl,zeros(size(imgmdl(:,:,1))));
for i=1:3 
    imgmdl(:,:,i)=imadjust(imgmdl(:,:,i));
end
set(rS,'z',current_Z)
set(rS,'PFS',1);
%% show image in figure 3
figure(3)
clf
subplot('position',[0 0 1 1]);
imshow(imgmdl,[],'initialmagnification','fit')

%% add rectangles
hold on
for i=1:size(Qdata.Value,1)
    x=[Qdata.Value(i,1)-tileSize/2; Qdata.Value(i,1)+tileSize/2];
    y=[Qdata.Value(i,2)-tileSize/2; Qdata.Value(i,2)+tileSize/2];
  
    plot([x(1); x(1)],y,'linewidth',3)
    plot([x(2); x(2)],y,'linewidth',3)
    plot(x,[y(1) y(1)],'linewidth',3)
    plot(x,[y(2) y(2)],'linewidth',3)
end

%% update Task Status
figure(4)
plotTaskStatusByType(rS)

%% Write image to disk
for i=1:size(Qdata.Value,1)
    % create a new Task with new filename
    old_filename=get(Tsk,'filename');
    TskTmp=set(Tsk,'filename',[old_filename '_' num2str(i)]);
    writeTiff(TskTmp,imgcrp{i},get(rS,'rootfolder'));
end

