%% Init
addpath ThirdParty\utilities\
global rS;
keep rS % delete everything but rS, rS could be a Scope or a empty double
        % from the global definition
ScopeConfigFileName='ScopeWithStageFocusThroughMMserial.cfg';

% if rS isn't a call the constractor of the Scope
if ~strcmp(class(rS),'Scope')
    rS=Scope(ScopeConfigFileName);
end
set(rS,'focusMethod','dualScanImageBased');
disp('Scope initialized');

%% Define focus parameters
setFocusParams(rS,'dualScanImageBased','Verbose',true)
setFocusParams(rS,'dualScanImageBased','Range',50)
setFocusParams(rS,'dualScanImageBased','NumOfStepsInScan',[10 10])
setFocusParams(rS,'dualScanImageBased','ROI',[100 200 100 200])
setFocusParams(rS,'dualScanImageBased','AcqParam',struct('Channel','Cy3-eye','Exposure',100))
setFocusParams(rS,'dualScanImageBased','ConvKern',[0 -1 0; -1 0 1; 0 1 0])

%% autofocus
zorg=get(rS,'z');
set(rS,'z',get(rS,'z')+20)
img=acqImg(rS,'cy3',100);
z=get(rS,'z');
autofocus(rS);
img2=acqImg(rS,'cy3',100);
z2=get(rS,'z');

%% plot
figure(1)
clf
subplot(2,2,1)
imshow(img)
title(['not in focus Z=' num2str(z)]);
subplot(2,2,2)
imshow(img2)
title(['dual scan focus Z=' num2str(z2)]);

%% For single focus
setFocusParams(rS,'singleScanImageBased','Verbose',true)
setFocusParams(rS,'singleScanImageBased','Range',50)
setFocusParams(rS,'singleScanImageBased','NumOfStepsInScan',20)
setFocusParams(rS,'singleScanImageBased','ROI',[100 200 100 200])
setFocusParams(rS,'singleScanImageBased','AcqParam',struct('Channel','Cy3-eye','Exposure',100))
setFocusParams(rS,'singleScanImageBased','ConvKern',[0 -1 0; -1 0 1; 0 1 0])

%% autofocus
set(rS,'focusmethod','singleScanImageBased');
set(rS,'z',zorg+20)
img=acqImg(rS,'cy3',100);
z=get(rS,'z');
autofocus(rS);
img2=acqImg(rS,'cy3',100);
z2=get(rS,'z');

%%
subplot(2,2,3)
imshow(img)
title(['not in focus Z=' num2str(z)]);
subplot(2,2,4)
imshow(img2)
title(['dual scan focus Z=' num2str(z2)]);
