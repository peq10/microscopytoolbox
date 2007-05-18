function rS = Scope(config_file,ObjectiveLbl)
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

%% Additional properties not part of Stage or MMC: 
%root folder
rS.rootFolder='D:\';

%focus method
rS.focusMethod='ASI';

%Current Objective 
% if value was not supplied, ask the user
if ~exist('ObjectiveLbl','var')
    
    disp('What Objective are you using?, please tell');
    disp('==========================================');
    disp('1 - Nikon 40X Plan Apo')
    disp('2 - Nikon 20X Plan Fluor DIC')
    disp('3 - Nikon 20X Plan Fluor')
    disp('4 - Nikon 10X Plan Fluor')

    ObjectiveLbl=input('Please chose a number (1/2/3/4)')
end
% set it in mmc
rS.mmc.setState('Objective',ObjectiveLbl);

% load the pixel sizes from file
pxlsz=csvread('PixelSizeList.csv');
pxlsz=sorrows(pxlsz);
rS.pxlsz=pxlsz(:,2);

%% add AcqFcn to the path
addpath AcqFcn

rS=class(rS,'Scope');



