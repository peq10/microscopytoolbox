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
                                          'Exposure',...
                                          'Channels',...
                                          'Binning');
%% goto XYZ
set(rS,'xy',[X Y],'z',Z);
figure(3)
plot(X,Y,'or');
%% autofocus
autofocus(rS);

%% snap images
img=acqImg(rS,Channels,Exposure);

%% Write image to disk
writeTiff(md,img); 

set(rS,'lastImage',img(:,:,1)); 

figure(1)
imshow(img(:,:,1),[])
