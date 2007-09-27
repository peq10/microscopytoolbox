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
img=acqImg(rS,ExposureDetails);

%% Write image to disk
writeTiff(md,img); 

set(rS,'lastImage',img(:,:,1)); 

figure(1)
imshow(img(:,:,1),[])
