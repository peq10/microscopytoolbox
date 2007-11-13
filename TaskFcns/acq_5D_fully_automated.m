function Tsk=acq_5D_fully_automated(Tsk) 

global rS;

tileSize=256;

%% get the crnt acq details 
[X,Y,Exposure,Channels,Z,Qdata]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'stageZ',...
                                          'Qdata');
%% goto XYZ
set(rS,'xy-slow',[X Y])
%% implement focalPointGuess
% Zguess=guessFocalPlane(rS,X,Y);
% set(rS,'Z',Zguess);

%% wait for perfect focus

set(rS,'pfs',1)
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
        
%% acquire stack
set(rS,'PFS',0);
Tsk=set(Tsk,'DimensionOrder','XYCZT');
current_Z=get(rS,'z');
for i=1:length(Z)
    set(rS,'z',current_Z+Z(i));
    img(:,:,:,i)=acqImg(rS,Channels,Exposure); %#ok<AGROW>
end
set(rS,'z',current_Z)
set(rS,'PFS',1);

%% show image in figure 3
figure(3)
subplot('position',[0 0 1 1])
clf
red=imadjust(max(img(:,:,1,:),[],4));
green=imadjust(max(img(:,:,2,:),[],4));
imshow(cat(3,red,green,zeros(size(red))),'initialmagnification','fit')

%% add rectangles
% shift cell centers if needed
Qdata.Value(:,1)=max(ceil(Qdata.Value(:,1)),tileSize/2+1);
Qdata.Value(:,1)=min(floor(Qdata.Value(:,1)),size(img,2)-tileSize/2);
Qdata.Value(:,2)=max(ceil(Qdata.Value(:,2)),tileSize/2+1);
Qdata.Value(:,2)=min(floor(Qdata.Value(:,2)),size(img,1)-tileSize/2);

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
plotTaskStatus(rS)
plotFocalPlaneGrid(rS,2);

%% Write image to disk
for i=1:size(Qdata.Value,1)
    % crop
    indx=(Qdata.Value(i,1)-tileSize/2):(Qdata.Value(i,1)+tileSize/2);
    indy=(Qdata.Value(i,2)-tileSize/2):(Qdata.Value(i,2)+tileSize/2);
    imgcrp=img(indy,indx,:,:,:);
    % create a new Task with new filename
    old_filename=get(Tsk,'filename');
    TskTmp=set(Tsk,'filename',[old_filename '_' num2str(i)]);
    writeTiff(TskTmp,imgcrp,get(rS,'rootfolder'));
end
