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

% the task buffer and schedule (the schedule carry the task id in the right order)
rS.TaskBuffer=[];
rS.TaskSchedule=[]; 


% Focus points - This is a list of points where rS know it had good focus
% existing points are needed for rS to be able to guess another point
rS.FocusPoints=[]; %[X Y Z T]
rS.FocusPointHistory=60; %Number of seconds that are used in the updateFocalPlaneGrid 
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
% pxlsz=csvread('PixelSizeList.csv');
% pxlsz=sortrows(pxlsz);
rS.pxlsz=0.065;

rS.focusParams=[]; %will be updated in first call for getFocusParams

%% create the object from struct
rS=class(rS,'Scope');
% set(rS,'channel','white');

% Init the channel property by closing and opening the tran light
set(rS,'channel','close')
set(rS,'channel','white')

%% add path
addpath TaskFcns


