function img = acqImg(rSin,Channel,Exposure)
%ACQIMG captues an image based on current acqDetails and enters it to DB
%   img=acqImg(rS,chnls,exposuretime)
%   rS        - the roboscope object
%   Channel   - the channel to image a cell array of strings
%   Exposure:  - the exposure time for all channels (a double array)

global rS;
rS=rSin;

[w,h,bd]=get(rS,'Width','Height','BitDepth');

% if no exposure settings, use current rS setting
if ~exist('Channel','var')
    Channel=get(rS,'channel');
end
if ~exist('Exposure','var')
    Exposure=get(rS,'exposure');
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
    img(:,:,i)=reshape(single(imgtmp)./(2^bd),w,h)';
end

set(rS,'lastimg',img);


