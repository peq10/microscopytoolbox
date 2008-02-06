function rS = Scope(config_file)
% Scope Constuctor of the Scope class
% creates a rS object based on the config file. If no config file is
% supplied, it create the Micro-Manager GUI which asks for the config file.
%
% All devices etc must be configured in the MMC config_file


%% Here we initialize the MMC core part of rS
% if config file is empty - start witht he GUI otherwise
% start using the cnfig file directly. 

import mmcorej.*;
rS.gui=[];
try
    if nargin ==0 || isempty(config_file)
        rS.gui=MMStudioPlugin;
        rS.gui.run('')
        uiwait(msgbox('Click me - I''m beutiful'))
        rS.mmc=rS.gui.getMMCoreInstance;
    else
        rS.mmc=CMMCore;
        rS.mmc.loadSystemConfiguration(config_file);
    end
    % try to load devices - if an error occurs unload and clean
catch
    rS.mmc.unloadAllDevices;
    rS=[]; %#ok<NASGU>
    uiwait(msgbox('An error occured during device loading - please close MM, correct the hardware problema and try again'))
    error('An error occured when loading devices - rS is not a functional Roboscope! \n %s',lasterr);
end

%% names of devices in the configuration file. 
rS.XYstageName='XY-Stage';
rS.ZstageName='Z-Stage';
rS.COM='COM2'; %the focus port for ASI 
rS.OBJName='OBJ'; % the GroupConfig for the objectives
rS.ChannelName='Channel';
rS.LightPathName='LightPath';

%% Additional properties not part of Stage or MMC:
% task ID
rS.taskID=0;

%root folder - defaults is current 
rS.rootFolder='./';

% resolve error - default is yes
rS.resolveErrors=true;

% default focus method
rS.focusMethod='ASI';

% default scheduling method
rS.schedulingMethod='greedy'; 

% Units
rS.units.stageXY='micro-meter';
rS.units.stageZ='micro-meter';
rS.units.exposureTime='msec';
rS.units.acqTime='sec';

% the last image captured, only saving that one (but could be a 3 channel
% image as well...
rS.lastImage=[];

% create the defaults plots
Plots={'planned schedule',1,[10   597   350   309];
       'focal plane',2,[10   246   350   309];
       'image',3,[380   348   894   627];
       'task schedule',4,[ 10    40   364   169];
       'task status',5,[ 380    40   483   173]};
rS.plotInfo=cell2struct(Plots,{'type','num','position'},2);

% the task buffer and schedule (the schedule carry the task id in the right order)
rS.TaskBuffer=[];
rS.TaskSchedule=[]; 
rS.refreshSchedule=Inf;

% Focus points - This is a list of points where rS know it had good focus
% existing points are needed for rS to be able to guess another point
rS.FocusPoints=[]; %[X Y Z T]
rS.FocusPointHistory=1/1440; %Number of days that are used in the updateFocalPlaneGrid 
rS.FocusPointProximity=10; %the distance of points for which the history is relevant
rS.FocalPlaneGridSize=25;

% % set it in mmc
% rS.mmc.setState('Objective',ObjectiveLbl);

% load the pixel sizes from file
fid=fopen('PixelSizeList.csv');
C=textscan(fid,'%s %f');
fclose(fid);
rS.pxlsz.label=C{1};
rS.pxlsz.um=C{2};

rS.focusParams=[]; %will be updated in first call for getFocusParams

%% create the object from struct
rS=class(rS,'Scope');
% set(rS,'channel','white');

% Init the channel property by closing and opening the tran light
% set(rS,'channel','close')
% set(rS,'channel','white')

%% add path - "Plug-in" folders
addpath TaskFcns
addpath SchedulerFcns
addpath(['ThirdParty' filesep 'utilities'])

