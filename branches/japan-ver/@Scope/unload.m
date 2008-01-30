function unload(rS,config_file)
% unload : removes all devices from the MMC core
% if a config_file is supplied it first saves all the information of the
% system to a file named config_file. 
% 
% example: 
%         unload(rS)
%         unload(rS,'config.dump')
if exist('config_file','var')
    rS.mmc.saveSystemConfiguration(config_file);
end
rS.mmc.unloadAllDevices;
