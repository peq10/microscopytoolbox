function varargout = get(rS,varargin)
%GET properties of the Score object rS
%   for details on what the properties are see developer guide. 

varargout={};
% get: 
% X,Y,Z,Fcs,Channel,ExpTime
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'resolveErrors'
            varargout=[varargout; {rS.resolveErrors}];
        case 'refreshschedule'
            varargout=[varargout; {rS.refreshSchedule}];
        case 'obj'
            varargout=[varargout; {rS.mmc.getStateLabel('OBJ')}];
        case 'pfs'
            varargout=[varargout; {rS.mmc.isContinuousFocusEnabled}];
        case 'roi'
            varargout=[varargout; {rS.mmc.getROI}];
        case 'focalplanegridsize'
            varargout=[varargout; {rS.FocalPlaneGridSize}];
        case 'focalplane'
            try
                fcspnts=get(rS,'focuspoints');
                x=fcspnts(:,1);
                y=fcspnts(:,2);
                z=fcspnts(:,3);
                n=rS.FocalPlaneGridSize;
                [X,Y]=meshgrid(linspace(min(x),max(x),n),linspace(min(y),max(y),n));
                Z=gridfit(x,y,z,X(1,:),Y(:,1), 'smooth',10,'extend','always');
                varargout=[varargout; {cat(3,X,Y,Z)}];
            catch %if cannot interpolate a grid
                varargout=[varargout; {[]}];
            end
        case 'focuspointshistory'
            varargout=[varargout; {rS.FocusPointsHistory}];
        case 'focuspointsproximity'
            varargout=[varargout; {rS.FocusPointsProximity}];
        case 'focuspoints'
            varargout=[varargout; {rS.FocusPoints(rS.FocusPoints(:,5)==1,:)}];
        case 'allfocuspoints'
            varargout=[varargout; {rS.FocusPoints}];
        case 'x'
            varargout=[varargout; {rS.mmc.getXPosition(rS.XYstageName)}];
        case 'y'
            varargout=[varargout; {rS.mmc.getYPosition(rS.XYstageName)}];
        case 'z'
            varargout=[varargout; {rS.mmc.getPosition(rS.ZstageName)}];
        case 'channel'
             varargout=[varargout; {char(rS.mmc.getCurrentConfig('Channel'))}];
        case 'exposure'
            varargout=[varargout; {rS.mmc.getExposure}];
        case 'width'
            varargout=[varargout; {rS.mmc.getImageWidth}];
        case 'height'
            varargout=[varargout; {rS.mmc.getImageHeight}];
        case 'bitdepth'
            varargout=[varargout; {rS.mmc.getImageBitDepth}];
        case 'rootfolder'
            varargout=[varargout; {rS.rootFolder}];
        case 'pixelsize'
            varargout=[varargout; {rS.pxlsz.um(strcmp(rS.pxlsz.label,get(rS,'OBJ')))}];
        case 'objective'
            varargout=[varargout; {rS.mmc.getStateLabel('Objective')}];
        case 'focusmethod'
            varargout=[varargout; {rS.focusMethod}];
        case 'schedulingmethod'
            varargout=[varargout; {rS.schedulingMethod}];
        case 'stagebusy'
            varargout=[varargout; {rS.mmc.deviceBusy(rS.XYstageName) | rS.mmc.deviceBusy(rS.XYstageName)}];
        case 'focusscore'
            % this is "hack" will need to change with autofocus device
            % it contains ASI specifics that should go away...
            cmdstr='rdadc z';
            rS.mmc.setSerialPortCommand(rS.COM,cmdstr,char(13))
            str=char(rS.mmc.getSerialPortAnswer(rS.COM,char(13)));
            str=regexprep(str,':A','');
            varargout=[varargout; {str2double(str)}];
        case {'focusrange',...
              'focusspeed',...
              'focussearchdirection',...
              'focususehilldetect',...
              'focushilldetectheight',...
              'focustime'}
          varargout=[varargout; {getFocusParams(rS,varargin{i})}];
        case 'currnettaskid'
            varargout=[varargout; {rS.taskID}];
        case 'isrunning'
            varargout=[varargout; {rS.isRunning}];
        case 'stagespeed.x'
            [ok,spd]=cmdStg(rS,'getSpeed','X');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'stagespeed.y'
            [ok,spd]=cmdStg(rS,'getSpeed','Y');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'stagespeed.z'
            [ok,spd]=cmdStg(rS,'getSpeed','Z');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'lastimage'
            varargout=[varargout; {rS.lastImage}];
        case 'binning'
            varargout=[varargout; {str2double(rS.mmc.getProperty('DigitalCamera','Binning'))}];
        case 'autoshutter'
            varargout=[varargout; {rS.getAutoShutter}];
        case 'progressbarhandle'
            varargout=[varargout; {rS.statusBarHandle}];
        otherwise
            warning('Throopi:Property:get:Scope',['property: ' varargin{i} ' does not exist in Scope class']) 
    end
end

