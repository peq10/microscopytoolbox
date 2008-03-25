function varargout=dualScanImageBased(rSin)
% an image based / software autofocus function that does two scans
% a coarse one to find regin and second run to find exact focus
% in both runs it uses the gradient based score function

% make sure we're using the global rS
global rS;
rS=rSin;

%% get param and check them for this focus function

% get the focus parameters
FocusParam=get(rS,'focusParams');

try % to define all parameters based on the FocusParam struct
    % number of steps is scan must be a 2 element vecotr
    NumOfStepsInScan=FocusParam.NumOfStepsInScan;
    if numel(NumOfStepsInScan)~=2
        error('If you call ''dualScanImageBased'' you must have 2 values in the ''NumOfStepsInScan'' focus parameter');
    end
    ScanRange(1)=0.5*FocusParam.Range;
    % the real scan would be - ScaneRange/2 -> + ScanRagne / 2
    % here for fake acq we make sure that the entire
    % stack is in scan range
    ScanRange(2)=ScanRange(1)/NumOfStepsScan(1)*1.1; % plus imnux that value

    % details required for the focus
    ROI=FocusParam.ROI;
    ConvKern=FocusParam.ConvKern;

    % AcqParam is a struct where the field is the property name and the
    AcqParam=FocusParam.AcqParam;

catch
    lasterr;
    error('At least one parameters for the focus function ''dualScanImageBased'' were not define in the ''FocusParam'' struct of rS');
end

Zres=0.01; % 10 nm resolution

%% defind the focus functions
f=@(img) sum(sum(filter2(ConvKern,img(ROI(1):ROI(2),ROI(3):ROI(4)).^2))); % gradient square


%% First coarse scan
Zcrnt=get(rS,'z');
Zscan1=Zcrnt+linspace(-ScanRange(1),ScanRange(1),NumOfStepsScan(1));

for i=1:NumOfStepsScan(1)
    Scr1(i)=getFcsScr(Zscan1(i),f,pth,Z);
end
Zpos1=min(Zscan1):Zres:max(Zscan1);
IntrpScr1=pchip(Zscan1,Scr1,Zpos1);
[blah,ix1]=max(IntrpScr1);
Zbst1=Zpos1(ix1);

%% Second fine scan
Zscan2=Zbst1+linspace(-ScanRange(2),ScanRange(2),NumOfStepsScan(2));

for i=1:NumOfStepsScan(2)
    Scr2(i)=getFcsScr(Zscan2(i),f,pth,Z);
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
set(rS,'Z',Zpos2(ix2));
inFocusFlag=1; % TODO: need to include some check to see if we think the AF worked.
 
% return success flag is asked for
if nargout
    varargout{1}=inFocusFlag;
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

    end % of nested function getFcsScr

end % of main function dualScanImageBased
