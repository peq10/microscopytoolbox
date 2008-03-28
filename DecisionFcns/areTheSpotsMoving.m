function [toSpawn,xtraData]=areTheSpotsMoving(img)

%% Define parameters:
lpkh=1000/2^16;  %min peak height
hpkh=16500/2^14;  %max peak height
pkdist=5;    %distance between peaks
edgdist=10;  %distance to edge
mindistance=2; %Minimun distance a spots has to move to be counted 
maxdistance=20; % Maximum distance (might help with matching outliers)
bps_param=[1,20]; % parameters for the bpass function
pkfnd_param=[0.1 1]; % parameter for the pkfnd function

%% find peaks in both timepoints 
imgleft=img(:,1:256,1);
imgright=img(:,257:512,1);
[pk1,allpk1]=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);

if isempty(pk1)
    toSpawn=0;
    xtraData=[];
    return
end

% now for the second timepoint
imgleft=img(:,1:256,2);
imgright=img(:,257:512,2);
[pk2,allpk2]=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);
if isempty(pk2)
    toSpawn=0;
    xtraData=[];
    return
end

%% do gross alignment to acount for stage shift etc
ix=dsearchn(allpk2,allpk1);
if length(ix)<2 || length(allpk1)<2
    disp('didn''t find enough spots');
    toSpawn=0;
    xtraData=[];
    return
end
tfrm=cp2tform(allpk1,allpk2(ix,:),'linear conformal');
% [pk2_algn(:,1),pk2_algn(:,2)]=tforminv(tfrm,pk2(:,1),pk2(:,2));
% I don't get it - why do I have to apply the transformation twice?
pk2_algn=[pk2 ones(size(pk2,1),1)]*tfrm.tdata.Tinv;%*tfrm.tdata.Tinv;
pk2_algn=pk2_algn(:,1:2);

imgrgb=cat(3,imadjust(imgleft),imadjust(imgright),zeros(size(imgleft)));
figure(6)
set(5,'position',[1241  339  420 598]);
clf
imshow(imgrgb)
hold on
plot(pk1(:,1),pk1(:,2),'mo',...
     pk2(:,1),pk2(:,2),'cx',...
     pk2_algn(:,1),pk2_algn(:,2),'bd')

%% find out if there is a point that after alignment 
% is in the right range of distances, if so spawn 
[blah,d]=dsearchn(pk1,pk2_algn); % find out the closest point
toSpawn = sum((d > mindistance) .* (d < maxdistance)) > 0;
xtraData = [];

if toSpawn
    ix=find((d > mindistance) .* (d < maxdistance));
    plot(pk1(ix,1),pk1(ix,2),'ws','markersize',20)
end
