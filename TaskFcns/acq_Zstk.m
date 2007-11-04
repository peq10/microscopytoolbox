function acq_Zstk(Tsk) 

global rS;



%% get the crnt acq details 
[X,Y,Exposure,Channels,Z]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'stageZ');
% Z=guessFocalPlane(rS,X,Y);

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
Tsk=set(Tsk,'DimensionOrder','XYZCT');
current_Z=get(rS,'z');
for i=1:length(Z)
    set(rS,'z',current_Z+Z(i));
    img(:,:,i)=acqImg(rS,Channels,Exposure);
end
set(rS,'z',current_Z)
set(rS,'PFS',1);
%% show image in figure 3
figure(3)
imshow(max(img,[],3),[],'initialmagnification','fit')

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% update Task Status
figure(4)
plotTaskStatus(rS)

%% Write image to disk
writeTiff(Tsk,img,get(rS,'rootfolder')); 
