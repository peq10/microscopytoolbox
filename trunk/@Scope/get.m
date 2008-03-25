function varargout = get(rSin,varargin)
% get : retrives the attributes of the Scope object rS
%   for details on what the properties are see doc 
%   can retrive multiple attributes in the same call
%
% example: 
%          [fldr,xpos,pfson]=get(rS,'rootFolder','x','pfs');

% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

varargout={};
% get: 
% X,Y,Z,Fcs,Channel,ExpTime
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'emgain' % the em-gain - must be defined in the config file.
            varargout=[varargout; {char(rS.mmc.getCurrentConfig(rS.EMgainName))}];
        case 'fakeacq' % a folder name to read fake images from
            varargout=[varargout; {rS.fakeAcquisition}];
        case 'printscreen' % a folder name to save print-screens into.
            varargout=[varargout; {rS.printScreenFolder}];
        case 'lightpath' % the light path: Camera or EyePiece
            lightpath=rS.mmc.getConfigGroupState(rS.LightPathName);
            varargout=[varargout; {lightpath}];
        case 'units' % a struct the defines what type of units are used by Roboscope for different stuff. <br> Defaults: stageXY='micro-menter'; stageZ='micro-meter'; exposureTime='msec'; acqTime='sec';
            varargout=[varargout; {rS.units}];
        case 'avaliabletskfcns' % returns a cell array of all the avaliable task functions
            tskfcn=dir(['TaskFcns' filesep '*.m']);
            varargout=[varargout; {{tskfcn(:).name}}];
        case 'pasttasksduration' % a struct with two fileds, fncStrUnq which contains a cell arrya of all past tasks acqFcn amd a durVector which contain the average time it took to perform that task. 
            
            PastTasks.fncStrUnq={''};
            PastTasks.durVector={0};

            % get past tasks
            ExecTsks=getTasks(rS,'status','executed');
            if isempty(ExecTsks)
                varargout=[varargout; {PastTasks}];
                return
            end

            % get past tasks names and durations
            [fncStr,AllDuration]=get(ExecTsks,'fcnstr','duration');
            if iscell(AllDuration)
                AllDuration=[AllDuration{:}];
            end
            if ~iscell(fncStr)
                fncStr={fncStr};
            end
            PastTasks.fncStrUnq=unique(fncStr);
            for ii=1:length(PastTasks.fncStrUnq)
                PastTasks.durVector{ii}=AllDuration(ismember(fncStr,PastTasks.fncStrUnq{ii}));
            end
            varargout=[varargout; {PastTasks}];
        case 'newtaskid' % a new Task id (each task has a unique id number)
            rS.taskID=rS.taskID+1;
            varargout=[varargout; {rS.taskID}];
        case 'plotinfo' % a struct that describes what ploting the plotAll methods should create. The struct have the following fields: 'type','num','positoin'. For more details check help plotAll
            varargout=[varargout; {rS.plotInfo}];
        case 'resolveerrors'  % a binary flag that determines whether Roboscope run mode, if true (default) rS will try to resolve errors (by clearing, initializing hardware components etc) 
            varargout=[varargout; {rS.resolveErrors}];
        case 'refreshschedule' % a number of task after which the rS will recalcualte the schedule (default Inf) this is useful in cases where the scheduling algorithm is using the average time per task and reschedule will help with this estimates.
            varargout=[varargout; {rS.refreshSchedule}];
        case 'obj' % the microscope objective as recorded in the GroupConfig whis name is in the rS.OBJ variable
            varargout=[varargout; {rS.mmc.getStateLabel(rS.OBJName)}];
        case 'pfs' % a binary flag whether the perfect focus is enabled
            varargout=[varargout; {rS.mmc.isContinuousFocusEnabled}];
        case 'roi' % the region of interest for the camera to capture
            varargout=[varargout; {rS.mmc.getROI}];
        case 'focalplanegridsize' % the size (n x n : default is 25) of the surface focal plane grid would be fitted, the higher this number the more rugged the surface could be
            varargout=[varargout; {rS.FocalPlaneGridSize}];
        case 'focalplane' % returns a focal plane that is calculated on the fly based on the focal points, e.g. points that were added using the addFocalPoints method. The calculation is done using the gridfit private function. 
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
        case 'focuspointshistory' % when a focal point is added, if there are others within the same neighbourhood (as defined in 'focuspointsproximity' property) that where taken more then 'focuspointshistory' minute ago, they are discarded from the list of focal points that are used for the fit. 
            varargout=[varargout; {rS.FocusPointsHistory}];
        case 'focuspointsproximity' % see 'focuspointshistory'
            varargout=[varargout; {rS.FocusPointsProximity}];
        case 'focuspoints' % returns points (x,y,z) that the scope thinks it had good focus in based on the fact that addFocalPoints was called with these points. This only returns "fresh" points, see 'focuspointshistory'
            varargout=[varargout; {rS.FocusPoints(rS.FocusPoints(:,5)==1,:)}];
        case 'allfocuspoints' % returns ALL the focus points regardless of the focuspointshistory / focuspointsproximity criteria
            varargout=[varargout; {rS.FocusPoints}];
        case 'x' % stage x position in um
            varargout=[varargout; {rS.mmc.getXPosition(rS.XYstageName)}];
        case 'y' % stage y position in um
            varargout=[varargout; {rS.mmc.getYPosition(rS.XYstageName)}];
        case 'xy' % a 1x2 array with the [x,y] position, set(rS,'xy',[x y]) is more efficient since it allow the stage to move in both x,y direction at the same time. 
            varargout=[varargout; {[get(rS,'x') get(rS,'y')]}];
        case 'z' % stage z position in um
            varargout=[varargout; {rS.mmc.getPosition(rS.ZstageName)}];
        case 'avaliablechannels' % all avaliable channels as defined in the MM config file.
            possibleConfigs=rS.mmc.getAvailableConfigs(rS.ChannelName);
            %TODO convert vector<string> into character cell array
            varargout=[varargout; possibleConfigs];
        case 'channel' % a Channel group as defined in the MM config 
             varargout=[varargout; {char(rS.mmc.getCurrentConfig(rS.ChannelName))}];
        case 'exposure' % camera exposure time in ms
            varargout=[varargout; {rS.mmc.getExposure}];
        case 'width' % image width in pixel - queried from mmc
            varargout=[varargout; {rS.mmc.getImageWidth}];
        case 'height' % image height in pixel - queried from mmc
            varargout=[varargout; {rS.mmc.getImageHeight}];
        case 'bitdepth' % image bit depth (2^bd) levels of gray - queried from mmc
            varargout=[varargout; {rS.mmc.getImageBitDepth}];
        case 'rootfolder' % where to save all the images
            varargout=[varargout; {rS.rootFolder}];
        case 'pixelsize' % in microns for the current optical configuration - queried from mmc
            %TODO fox pixel size to be compatible with MM 
            varargout=[varargout; {rS.pxlsz.um(strcmp(rS.pxlsz.label,get(rS,rS.OBJName)))}];
        case 'focusmethod' % what is the currrent focus method - STILL PERLIMINARY needs more work
            varargout=[varargout; {rS.focusMethod}];
        case 'avaliableschedulers' % the avaliable schedualing methods that are defined in the SchedualerFcns folder
            dr=dir('SchedulerFcns/*.m');
            m=cell(size(dr));
            [m{:}]=dr.name;
            m=regexprep(m,'.m','');
            varargout=[varargout; {m}];
        case 'schedulingmethod' % what is the current scheduling methods, avaliable schduling methods are all the files in the SchedulerFcns folder
            varargout=[varargout; {rS.schedulingMethod}];
        case 'stagebusy' % a flag that nors whether the stage is currently busy. 
            varargout=[varargout; {rS.mmc.deviceBusy(rS.XYstageName) | rS.mmc.deviceBusy(rS.XYstageName)}];
        case 'focusscore' % the focus score as calculated by the current 'focusmethod' - TODO: move to MMC implementation
            % this is "hack" will need to change with autofocus device
            % it contains ASI specifics that should go away...
            cmdstr='rdadc z';
            rS.mmc.setSerialPortCommand(rS.COM,cmdstr,char(13))
            str=char(rS.mmc.getSerialPortAnswer(rS.COM,char(13)));
            str=regexprep(str,':A','');
            varargout=[varargout; {str2double(str)}];
        case 'focusrange' % TODO implement this focus parameters via mmc
        case  'focusspeed' % TODO implement this focus parameters via mmc
        case 'focussearchdirection' % TODO implement this focus parameters via mmc
        case  'focususehilldetect' % TODO implement this focus parameters via mmc
        case  'focushilldetectheight' % TODO implement this focus parameters via mmc
        case  'focustime'  % TODO implement this focus parameters via mmc
%          OLD IMPLEMETATION USING getFocusParam, need to move to mmc 
%           varargout=[varargout; {getFocusParams(rS,varargin{i})}];
        case 'currnettaskid' % the id number of the current task
            varargout=[varargout; {rS.taskID}];
        case 'stagespeed.x' % the speed um/sec of the stage in the x dimension - TODO: change implementation to mmc . ONLY CONFIGURED FOR ASI STAGE NOT THROUGH MMC
            [ok,spd]=cmdStg(rS,'getSpeed','X');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'stagespeed.y' % the speed um/sec of the stage in the y dimension - ONLY CONFIGURED FOR ASI STAGE NOT THROUGH MMC TODO: change implementation to mmc
            [ok,spd]=cmdStg(rS,'getSpeed','Y');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'stagespeed.z' % the speed um/sec of the stage in the x dimension - ONLY CONFIGURED FOR ASI STAGE NOT THROUGH MMC TODO: change implementation to mmc
            [ok,spd]=cmdStg(rS,'getSpeed','Z');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {spd}];
        case 'lastimage' % the last image that was captured (could be multi channeled) by acqImg
            varargout=[varargout; {rS.lastImage}];
        case 'binning' % current camera binning (MMC)
            varargout=[varargout; {str2double(rS.mmc.getProperty('DigitalCamera','Binning'))}];
        case 'autoshutter' % autoshutter (true/false) an MMC property
            varargout=[varargout; {rS.getAutoShutter}];
        otherwise
            warning('Throopi:Property:get:Scope',['property: ' varargin{i} ' does not exist in Scope class']) 
    end
end

