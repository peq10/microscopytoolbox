function img = acqImg(rS,ExpDetails)
%ACQIMG captues an image based on current acqDetails and enters it to DB
%   img=acqImg(rS,chnls,exposuretime)
%   rS            - the roboscope object
%   ExpDetails (optional - if not acquire with currnet settings)
%                 - array of structs, each having two fields:
%                    * channel:  the channel to image
%                    * exposure: the exposure time for this channel

[w,h,bd]=get(rS,'Width','Height','BitDepth');
crnt_chnl=get(rS,'channel');

% if no exposure settings, use current rS setting
if ~exist('ExpDetails','var')
    [ExpDetails.channel,ExpDetails.exposure]=get(rS,'channel','exposure');
end

n=length(ExpDetails);
img=zeros(h,w,n); % notice the traspose element in the loop

for i=1:n
    % set autoshutter only for whitelight
    autoshutter=1;
    if strcmpi(ExpDetails(i).channel,'White')
        autoshutter=0;
    end
    set(rS,'AutoShutter',autoshutter,...
           'Channel',ExpDetails(i).channel,...
           'Exposure',ExpDetails(i).exposure);
    rS.mmc.snapImage;
    imgtmp=rS.mmc.getImage;
    img(:,:,i)=reshape(double(imgtmp)./(2^bd),w,h)';
end

set(rS,'channel',crnt_chnl);


