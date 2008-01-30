function loadDevices(rS,config_file)
% loadDevices :  loads all the devices based on conig_file
%   basically passes this config_file into mmc
%
% example: loadDevices(rS,'config.dump')

rS.mmc.loadSystemConfiguration(config_file);