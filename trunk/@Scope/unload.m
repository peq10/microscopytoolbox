function unload( rS)
%UNLOAD unloads all devices and close the serial port for the stage
rS.mmc.unloadAllDevices;
fclose(rS.Stg);