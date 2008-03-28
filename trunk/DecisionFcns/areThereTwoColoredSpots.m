function [toSpawn,xtraData]=areThereTwoColoredSpots(img)

%% Define parameters:
lpkh=1000/2^16;  %min peak height
hpkh=16500/2^14;  %max peak height
pkdist=5;    %distance between peaks
edgdist=10;  %distance to edge
bps_param=[1,20]; % parameters for the bpass function
pkfnd_param=[0.1 1]; % parameter for the pkfnd function

%% find peaks 
imgleft=img(:,1:256,1);
imgright=img(:,257:512,1);
pk=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);

toSpawn=~isempty(pk);
xtraData.img=img;
xtraData.pk=pk;

imgrgb=cat(3,imadjust(imgleft),imadjust(imgright),zeros(size(imgleft)));
figure(5)
set(5,'position',[1241  339  420 598]);
clf
imshow(imgrgb)
hold on
if ~isempty(pk)
    plot(pk(:,1),pk(:,2),'mo')
end
