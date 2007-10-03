function flushStageOutputBuffer(rSin)

str='notempty';
global rS;
rS=rSin;
rS.focusParams=[];

while ~isempty(str)
    str=char(rS.mmc.getSerialPortAnswer(rS.COM,char(13)));
end