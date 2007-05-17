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

%% Here we do the stage
Stg=serial('COM2','BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1);
Stg.Terminator='CR';
fopen(Stg);
rS.Stg=Stg;

%% root folder
rS.rootFolder='D:\';

%% add AcqFcn to the path
addpath AcqFcn

rS=class(rS,'Scope');



