function [inFocusFlag,bestZ,allZ,allScrs]=dualScanImageBased(rSin)
% an image based / software autofocus function that does two scans
% a coarse one to find regin and second run to find exact focus
% in both runs it uses the gradient based score function

% make sure we're using the global rS
global rS;
rS=rSin;
t0=now;

%% get param and check them for this focus function

try % to define all parameters based on the FocusParam struct
    % number of steps is scan must be a 2 element vecotr
    Verbose=getFocusParams(rS,'dualScanImageBased','Verbose');
    NumOfStepsInScan=getFocusParams(rS,'dualScanImageBased','NumOfStepsInScan');
    ScanRange=getFocusParams(rS,'dualScanImageBased','Range');
    SNR=getFocusParams(rS,'dualScanImageBased','SNR');
    % details required for the focus
    ROI=getFocusParams(rS,'dualScanImageBased','ROI');
    ConvKern=getFocusParams(rS,'dualScanImageBased','ConvKern');

    % AcqParam is a struct where the field is the property name and the
    AcqParam=getFocusParams(rS,'dualScanImageBased','AcqParam');

catch
    lasterr;
    error('At least one parameters for the focus function ''dualScanImageBased'' were not define in the ''FocusParam'' struct of rS');
end

Zres=0.01; % 10 nm resolution

%% defind the focus functions
f=@(img) sum(sum(filter2(ConvKern,img(ROI(1):ROI(2),ROI(3):ROI(4))).^2)); % gradient square


%% First coarse scan
Zcrnt=get(rS,'z');
Zscan1=Zcrnt+linspace(-ScanRange(1),ScanRange(1),NumOfStepsInScan(1));

for i=1:NumOfStepsInScan(1)
    Scr1(i)=getFcsScr(Zscan1(i));
end
Zpos1=min(Zscan1):Zres:max(Zscan1);
IntrpScr1=pchip(Zscan1,Scr1,Zpos1);
[blah,ix1]=max(IntrpScr1);
Zbst1=Zpos1(ix1);

%% Second fine scan
Zscan2=Zbst1+linspace(-ScanRange(2),ScanRange(2),NumOfStepsInScan(2));

for i=1:NumOfStepsInScan(2)
    Scr2(i)=getFcsScr(Zscan2(i));
end
% combine info from both scans
zz=[Zscan1 Zscan2];
[zz,ix]=unique(zz);
ss=[Scr1 Scr2];
ss=ss(ix);
Zpos2=min(zz):Zres:max(zz);
IntrpScr2=pchip(zz,ss,Zpos2);
[blah,ix2]=max(IntrpScr2);

% Finally, set rS to the best Z plane 
allZ=zz;
allScrs=ss;
% return success flag is asked for
bestZ=Zpos2(ix2);

if prctile(allScrs,90)/prctile(allScrs,10)>SNR
    inFocusFlag=1; % TODO: need to include some check to see if we think the AF worked.
else
    inFocusFlag=0;
end

%% nested functions for calculating score

    function scr=getFcsScr(z)
        set(rS,'Z',z);
        acqParamFldName=fieldnames(AcqParam);
        % change rS to autofocus state
        for ii=1:length(acqParamFldName)
            set(rS,acqParamFldName{ii},AcqParam.(acqParamFldName{ii}));
        end
        img=acqImg(rS); % calling without parameters since we just set them up
        % and acqImg will use stuff as defined in rS as default
        scr=f(img);
        if Verbose, fprintf('time: %s z: %g scr: %g\n',datestr(now-t0,13),z,scr); end


    end % of nested function getFcsScr

end % of main function dualScanImageBased
