function display(rS)
% display show details of rS object
% queries MMC and displays a list of loaded devices
% This method is called when rS is run in the command line
%
% example: 
%         rS
%         display(rS)

disp('Throopi the roboscope:')
disp('======================')
disp(['uses CMMCore version: ' char(rS.mmc.getVersionInfo)])
disp('   ')
disp('Devices loaded:')
disp('---------------')
str=rS.mmc.getLoadedDevices;
for i=0:str.size-1
    disp(char(str.get(i)))
end



