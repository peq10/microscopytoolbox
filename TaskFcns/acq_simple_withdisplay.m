function acq_simple(Tsk) 
%SIMPLEACQ callback function to be used by by AcqSeq objects
%   
% Outline: 
% 1. get the current number in the sequence
% 2. goto the right xyz position, 
% 3. autofocus
% 4. expose & snap an image
% 5. save to disk

global rS;

%% get the crnt acq details 
[X,Y,Z,Exposure,Channels,Binning]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'stageZ',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning');
%% goto XYZ
set(rS,'xy',[X Y],'z',Z);
figure(1)
plot(X,Y,'or');
%% autofocus
autofocus(rS);

%% update Tsk object so the value I write to disk are actual not theoretical
Tsk=set(Tsk,'planetime',now,'stagex',get(rS,'x'),'stagey',get(rS,'y'),'stagez',get(rS,'z'));

%% snap images
img=acqImg(rS,Channels,Exposure);

%% Write image to disk
writeTiff(Tsk,img,get(rS,'rootfolder')); 
set(rS,'lastImage',img); 

%% show image
showImg(Tsk,img(:,:,1),2)
