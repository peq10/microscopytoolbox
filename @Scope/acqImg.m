function img = acqImg(rSin,Channel,Exposure)
% acqImg : performs image acquisition 
% captues a (multichannel) image based on Channel / Exposure arguments.
% 
% sets the channel and exposure for each channel  
%   rS        - the roboscope object
%   Channel   - the channel to image a cell array of strings (single char
%               will be converted to a cell array with single element)
%   Exposure:  - the exposure time for all channels (a double array)
%   img - a 3D matrix where size(img,3)==length(Channels)
%  
% example: 
%          img = acqImg(rS,'FITC',100) 
%          img = acqImg(rS,{'FITC','Cy3'},{300,100})
%          img = acqImg(rS)

global rS;
rS=rSin;

% if channels is not a cell array make it oue
if ~iscell(Channel)
    Channel={Channel};
end

[w,h,bd]=get(rS,'Width','Height','BitDepth');


% check if its a fake acquisition
if ~isempty(get(rS,'fakeacq'))
    dr=dir(get(rS,'fakeacq'));
    dr=dr(3:end);
    dr=dr(randperm(length(dr)));
    img=imread(fullfile(get(rS,'fakeacq'),dr(1).name));
    rS.lastImage=img;
    img=repmat(imresize(img(:,:,1),[h w]),[1 1 length(Channel)]);
    pause(1)
    return
end


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

% Only acqImg can change lastImage attribute - 
% so ite not done via reaugular set/get
rS.lastImage=img;


