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
md=get(Tsk,'MetaData'); 
[X,Y,Z,ExposureDetails]=get(md,'stage.X','stage.Y','stage.Z','ExposureDetails');

%% goto XYZ
set(rS,'xy',[X Y]);
set(rS,'z',Z);
figure(3)
plot(X,Y,'or');
%% autofocus
autofocus(rS);

%% snap images
img=acqImg(rS,ExposureDetails(1));
dZ=get(Tsk,'UserData');
crZ=get(rS,'z');
for i=1:length(dZ)
    set(rS,'z',crZ+dZ(i));
    waitFor(rS,'stage')
    img(:,:,i+1)=acqImg(rS,ExposureDetails(2));
end

%% Write image to disk
writeTiff(md,img); 

set(rS,'lastImage',img(:,:,2)); 

figure(1)
imshow(img(:,:,1),[])
figure(2)
imshow(img(:,:,2),[])


% z=get(rS,'z'); 
% dz=2;
% z=z-dz;
% set(rS,'z',z);
% updateStatusBar(rS,0)
% img(:,:,1)=acqImg(rS,Channels,Exposure);
% imshow(img(:,:,1),[],'initialmagnification','fit')
% z=z+dz;
% set(rS,'z',z);
% updateStatusBar(rS,0.33)
% img(:,:,2)=acqImg(rS,Channels,Exposure);
% imshow(img(:,:,2),[],'initialmagnification','fit')
% z=z+dz;
% set(rS,'z',z);
% updateStatusBar(rS,0.66)
% img(:,:,3)=acqImg(rS,Channels,Exposure);
% imshow(img(:,:,1),[],'initialmagnification','fit')
% img=max(img,[],3);
% set(rS,'z',z);
% updateStatusBar(rS,1)