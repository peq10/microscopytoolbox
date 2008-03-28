function Tsk=acqBurstMode(rSin,imgNum,Tsk)
% acquires using MM burst mode

global rS;
rS=rSin;

[w,h,bd]=get(rS,'Width','Height','BitDepth');
chnl=get(Tsk,'channels');

filename=fullfile(get(rS,'rootfolder'),get(Tsk,'filename'));
set(rS,'exposure',get(Tsk,'exposure'),...
       'channel',chnl{1});
   
% rS.mmc.stopSequenceAcquisition;
rS.mmc.snapImage;
rS.mmc.stopSequenceAcquisition;
rS.mmc.startSequenceAcquisition(imgNum,10);
rS.mmc.getBufferIntervalMs
pause(10*rS.mmc.getBufferIntervalMs/1000)
cnt=0;
trials=0;
fprintf('\n%03.0f',cnt)
while cnt<imgNum
    try
        img=rS.mmc.popNextImage;
        cnt=cnt+1;
        trials=0;
        t(cnt)=rS.mmc.getBufferIntervalMs;
        if cnt==1
            disp(['in burst mode exposure is ' num2str(t(1)) 'msec.     '])
        end
        img=reshape(single(img)./(2^bd),w,h)';
%         TskSeq(cnt)=updateMetaData(Tsk);
%         writeTiff(Tsk,img,get(rS,'rootfolder'));
        imwrite(img,[filename '_' num2str(cnt) '.tiff']);
        fprintf('\b\b\b%03.0f',cnt)
        fprintf('\nBuffer overflow: %g\n  Buffer capacity %g\n',rS.mmc.isBufferOverflowed,rS.mmc.getRemainingImageCount );
    catch
        fprintf('Buffer overflow: %g\n  Buffer capacity %g\n',rS.mmc.isBufferOverflowed,rS.mmc.getRemainingImageCount );
        
        trials=trials+1;
        pause(0.1)
        disp('pausing');
%         fprintf('couldn''t get image %g - trying again for the %g times\n',cnt,trials);
        lasterr;
        if trials>1000
            break
        end
    end
end
rS.mmc.stopSequenceAcquisition;
MD=concat(TskSeq);
MD=addQdata(MD,'type','Interval',...
               'value',t,...
               'description','Buffer interval',...
               'label','ms');
updateTiffMetaData(MD,get(rS,'rootfolder'));
rS.lastImage=img;


    