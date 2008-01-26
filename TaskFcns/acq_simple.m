% function Tsk=acq_simple(Tsk) 

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
[X,Y,Exposure,Channels,Binning]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning');

%% goto XYZ
set(rS,'xy',[X Y],'binning',Binning);

Tsk=set(Tsk,'planetime',now,... % time the image was taken
            'stagex',get(rS,'x'),... % real position (xyz)
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'));
        
%% snap image
img=acqImg(rS,Channels,Exposure);

%% Analyze image
% automatic thresholding
bw=im2bw(img,graythresh(img));
[lbl,n]=bwlabel(bw);

%% Write image to disk
if n>100
    writeTiff(Tsk,img,get(rS,'rootfolder'));
end


