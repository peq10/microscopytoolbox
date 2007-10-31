function display(rS)
%DISPLAY show details of Scope object

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



