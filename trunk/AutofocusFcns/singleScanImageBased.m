function [inFocusFlag,bestZ,allZ,allScrs]=singleScanImageBased(rSin)
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
    Verbose=getFocusParams(rS,'singleScanImageBased','Verbose');
    NumOfStepsInScan=getFocusParams(rS,'singleScanImageBased','NumOfStepsInScan');
    ScanRange(1)=0.5*getFocusParams(rS,'singleScanImageBased','Range');
    % the real scan would be - ScaneRange/2 -> + ScanRagne / 2
    % here for fake acq we make sure that the entire
    % stack is in scan range
    ScanRange(2)=ScanRange(1)/NumOfStepsInScan(1)*1.1; % plus imnux that value

    % details required for the focus
    ROI=getFocusParams(rS,'singleScanImageBased','ROI');
    ConvKern=getFocusParams(rS,'singleScanImageBased','ConvKern');

    % AcqParam is a struct where the field is the property name and the
    AcqParam=getFocusParams(rS,'singleScanImageBased','AcqParam');

catch
    lasterr;
    error('At least one parameters for the focus function ''singleScanImageBased'' were not define in the ''FocusParam'' struct of rS');
end

Zres=0.01; % 10 nm resolution

%% defind the focus functions
f2=@(img) filter2(ConvKern,img(ROI(1):ROI(2),ROI(3):ROI(4))).^2; % gradient square
f=@(img) sum(sum(filter2(ConvKern,img(ROI(1):ROI(2),ROI(3):ROI(4))).^2)); % gradient square

%% First coarse scan
Zcrnt=get(rS,'z');
Zscan=Zcrnt+linspace(-ScanRange(1),ScanRange(1),NumOfStepsInScan(1));

for i=1:NumOfStepsInScan
    Scr(i)=getFcsScr(Zscan(i));
end
Zpos=min(Zscan):Zres:max(Zscan);
IntrpScr=pchip(Zscan,Scr,Zpos);
[blah,ix]=max(IntrpScr);
Zbst=Zpos(ix);

zz=Zscan;
ss=Scr;

% Finally, set rS to the best Z plane 
inFocusFlag=1; % TODO: need to include some check to see if we think the AF worked.
 
allZ=zz;
allScrs=ss;

% return success flag is asked for
inFocusFlag;
bestZ=Zpos(ix);

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

%         subplot(1,2,1)
%         flt=f2(img);
%         imshow(img(ROI(1):ROI(2),ROI(3):ROI(4)),[])
%         subplot(1,2,2)
%         imshow(flt,[])
%         drawnow
        if Verbose, fprintf('time: %s z: %g scr: %g\n',datestr(now-t0,13),z,scr); end


    end % of nested function getFcsScr

end % of main function singleScanImageBased
