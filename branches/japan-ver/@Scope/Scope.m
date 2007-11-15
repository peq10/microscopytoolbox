function rS = Scope(config_file)
%SCOPE Constuctor of the Score class
%   rS = Scope( config_file,objective,varargin )
%   
%   config_file goes directly to mmc for configuration and initialization
%   objective determine the pixel size

%% Here we initialize the MMC core part of rS
% if config file is empty - start witht he GUI otherwise
% start using the cnfig file directly. 

import mmcorej.*;
if nargin ==0 || isempty(config_file)
    rS.gui=MMStudioPlugin;
    rS.gui.run('')
    uiwait(msgbox('Click me - I''m beutiful'))
    rS.mmc=rS.gui.getMMCoreInstance;
else
    rS.mmc=CMMCore;
end
% rS.mmc=CMMCore;

%% try to load devices - if an error occurs unload and clean
try
    rS.mmc.loadSystemConfiguration(config_file);
catch
    rS.mmc.unloadAllDevices;
    rS=[];
    uiwait(msgbox('An error occured during device loading - please close MM, correct the hardware problema and try again'))
    error('An error occured when loading devices - rS is not a functional Roboscope!');
end

%% This is the stage/autofocus hacks
rS.XYstageName='XY-Stage';
rS.ZstageName='Z-Stage';
rS.COM='COM2'; %the focus port

%% Additional properties not part of Stage or MMC:
% task ID
rS.taskID=0;

%root folder
rS.rootFolder='D:\GiardiaDataBuffer';

% resolve error - default is yes
rS.resolveErrors=true;

% default focus method
rS.focusMethod='ASI';

% default scheduling method
rS.schedulingMethod='greedy'; 

% the last image captured, only saving that one (but could be a 3 channel
% image as well...
rS.lastImage=0;

% the task buffer and schedule (the schedule carry the task id in the right order)
rS.TaskBuffer=[];
rS.TaskSchedule=[]; 
rS.refreshSchedule=Inf;

% Focus points - This is a list of points where rS know it had good focus
% existing points are needed for rS to be able to guess another point
rS.FocusPoints=[]; %[X Y Z T]
rS.FocusPointHistory=1/1440; %Number of days that are used in the updateFocalPlaneGrid 
rS.FocusPointProximity=100; %the distance of points for which the history is relevant
rS.FocalPlaneGridSize=25;

% a flag to note whether scope is currently executing tasks
rS.isRunning=false;

% the handle for the statusbar
rS.statusBarHandle=[];
%Current Objective - TODO: get objective name from mmc config file. 
% if value was not supplied, ask the user
% if ~exist('ObjectiveLbl','var')
%     
%     disp('What Objective are you using?, please tell');
%     disp('==========================================');
%     disp('1 - Nikon 40X Plan Apo')
%     disp('2 - Nikon 20X Plan Fluor DIC')
%     disp('3 - Nikon 20X Plan Fluor')
%     disp('4 - Nikon 10X Plan Fluor')
% 
%     ObjectiveLbl=input('Please chose a number (1/2/3/4)');
% end
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

%% Other toolboxes
% addpath 



