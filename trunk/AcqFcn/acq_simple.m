function simpleAcq(obj, event,imshowFlag) %#ok<INUSD>
%SIMPLEACQ callback function to be used by by AcqSeq objects
%   
% Outline: 
% 1. get the current number in the sequence
% 2. goto the right xyz position, 
% 3. autofocus
% 4. expose & snap an image
% 5. save to disk

global rS;

%% find out current acquisition number
crnt=get(obj,'tasksExecuted')+1; 

%% get the crnt acq details 
UserData=get(obj,'UserData');
OMEs=UserData.OMEs;

[X,Y,Z,ExposureDetails]=get(OMEs(crnt),'stage.X','stage.Y','stage.Z','ExposureDetails');

%% goto XYZ
set(rS,'xyz',[X Y Z]);

%% autofocus
autofocus(rS);

%% snap images
img=acqImg(rS,ExposureDetails);

%% Replace last image in the UserData 
UserData.lastImage=img;

%% Write image to disk
imwrite(OMEs(crnt),img); 

%% imshow if necessary
if nargin > 2 || imshowFlag==1
    figure(gcf);
    [r,g,b]=get(OMEs(crnt),'display.r','display.g','display.b');
    % TODO potentially enhance image with DisplayOptions levels fields
    
    imshow(img(:,:,[r g b])); 
end
