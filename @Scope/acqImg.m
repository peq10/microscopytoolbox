function img = acqImg(rS,Channel,Exposure)
%ACQIMG captues an image based on current acqDetails and enters it to DB
%   img=acqImg(rS,chnls,exposuretime)
%   rS        - the roboscope object
%   Channel   - the channel to image a cell array of strings
%   Exposure:  - the exposure time for all channels (a double array)

[w,h,bd]=get(rS,'Width','Height','BitDepth');
crnt_chnl=get(rS,'channel');

% if no exposure settings, use current rS setting
if ~exist('ExpDetails','var')
    [Channel,Exposure]=get(rS,'channel','exposure');
end

n=length(Channel);
img=zeros(h,w,n); % notice the traspose element in the loop

for i=1:n
    % set autoshutter only for whitelight
    autoshutter=1;
    if strcmpi(Channel{i},'White')
        autoshutter=0;
    end
    set(rS,'AutoShutter',autoshutter,...
           'Channel',Channel{i},...
           'Exposure',Exposure(i));
    rS.mmc.snapImage;
    imgtmp=rS.mmc.getImage;
    img(:,:,i)=reshape(double(imgtmp)./(2^bd),w,h)';
end

set(rS,'channel',crnt_chnl);


