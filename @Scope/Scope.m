function rS = Scope(config_file)
%SCOPE Constuctor of the Score class
%   rS = Scope( config_file,objective,varargin )
%   
%   config_file goes directly to mmc for configuration and initialization
%   objective determine the pixel size
import mmcorej.*;
rS.mmc=CMMCore;
rS.mmc.loadSystemConfiguration(config_file);

Stg=serial('COM2','BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1);
Stg.Terminator='CR';
fopen(Stg);

rS.rootFolder='D:\';

rS.Stg=Stg;
rS=class(rS,'Scope');



