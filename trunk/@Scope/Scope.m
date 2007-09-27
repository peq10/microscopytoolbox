function rS = Scope(config_file)
%SCOPE Constuctor of the Score class
%   rS = Scope( config_file,objective,varargin )
%   
%   config_file goes directly to mmc for configuration and initialization
%   objective determine the pixel size

%% Here we initialize the MMC core part of rS
import mmcorej.*;
rS.mmc=CMMCore;
rS.mmc.loadSystemConfiguration(config_file);

%% Close both shutters
% rS.mmc.setStateLabel('WhiteLight','0')
% rS.mmc.setStateLabel('Fluorescence','0')

%% This is the stage/autofocus hacks
rS.XYstageName='XY-Stage';
rS.ZstageName='Z-Stage';
rS.COM='COM2'; %the focus port

%% Additional properties not part of Stage or MMC:
% task ID
rS.taskID=0;

%root folder
rS.rootFolder='D:\GiardiaDataBuffer';

% default focus method
rS.focusMethod='ASI';

% default scheduling method
rS.schedulingMethod='Ants_TSP'; 

% the last image captured, only saving that one (but could be a 3 channel
% image as well...
rS.lastImage=0;

% the task buffer
rS.TaskBuffer=[];
rS.TaskSchedule=[]; 

% a flag to note whether scope is currently executing tasks
rS.isRunning=false;

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
% pxlsz=csvread('PixelSizeList.csv');
% pxlsz=sortrows(pxlsz);
rS.pxlsz=0.065;

rS.focusParams=[]; %will be updated in first call for getFocusParams

%% add folder to the path
addpath TaskFcns

% additional toolboxes
addpath(['ThirdParty' filesep 'xmltree'])

%% create the object from struct
rS=class(rS,'Scope');
% set(rS,'channel','white');

% Init the channel property by closing and opening the tran light
set(rS,'channel','close')
set(rS,'channel','white')

