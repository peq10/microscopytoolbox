function [toSpawn,xtraData]=areTheTwoColoredSpotsMoving(img)

%% Define parameters:
lpkh=1000/2^16;  %min peak height
hpkh=16500/2^14;  %max peak height
pkdist=5;    %distance between peaks
edgdist=10;  %distance to edge
mindistance=2; %Minimun distance a spots has to move to be counted 
maxdistance=20; % Maximum distance (might help with matching outliers)
bps_param=[1,20]; % parameters for the bpass function
pkfnd_param=[0.1 1]; % parameter for the pkfnd function

%% find peaks in both timepoints (why not find them in both colors separately?)

%TODO: change to the dual color thing 
% leftim=input(:,1:256);
% rightim(:,1:256)=input(:,257:512);
imgleft=img(:,:,1,1);
imgright=img(:,:,2,1);
[pk1,allpk1]=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);

if isempty(pk1)
    toSpawn=0;
    xtraData=[];
    return
end

% now for the second timepoint
imgleft=img(:,:,1,2);
imgright=img(:,:,2,2);
[pk2,allpk2]=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);
if isempty(pk2)
    toSpawn=0;
    xtraData=[];
    return
end
%% do gross alignment to acount for stage shift etc
ix=dsearchn(allpk2,allpk1);
tfrm=cp2tform(allpk1,allpk2(ix,:),'linear conformal');
% [pk2_algn(:,1),pk2_algn(:,2)]=tforminv(tfrm,pk2(:,1),pk2(:,2));
% I don't get it - why do I have to apply the transformation twice?
pk2_algn=[pk2 ones(size(pk2,1),1)]*tfrm.tdata.Tinv*tfrm.tdata.Tinv;
pk2_algn=pk2_algn(:,1:2);

imgrgb=cat(3,img(:,:,1,1),img(:,:,1,2),zeros(size(img(:,:,1,1))));
figure(1)
clf
imshow(imgrgb)
hold on
plot(pk1(:,1),pk1(:,2),'mo',...
     pk2(:,1),pk2(:,2),'cx',...
     pk2_algn(:,1),pk2_algn(:,2),'bd')

%% find out if there is a point that after alignment 
% is in the right range of distances, if so spawn 
[blah,d]=dsearchn(pk1,pk2_algn); % find out the closest point
toSpawn = sum((d > mindistance) + (d < maxdistance)) > 0;
xtraData = [];

%% %%%%%%%%%%%%%%%%%%%%%%% sub function %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pkgood,pk]=findGoodPeaks(leftim,rightim,hpkh,lpkh,edgdist,pkdst,bps_param,pkfnd_param)
% this function uses the peakfnd function to find peaks in both images
% based on Andrew's code
imgsz=size(leftim);
%% Find peaks in the left hand image
% b = bpass(leftim,1,5);   % 5 is the diameter of the blob you want to find.
b = bpass(leftim,bps_param(1),bps_param(2));
% pk = pkfnd(b,60,5);  % 60 is a threshold value, 5 is the diameter of
pk = pkfnd(b,pkfnd_param(1),pkfnd_param(2));
if isempty(pk)
    pkgood=[];
    return
end
ix=sub2ind(imgsz,pk(:,2),pk(:,1)); % we specify it as row colum not xy that why the order is 2 1
pkint=[pk leftim(ix) rightim(ix)]; %pkint has the intensity in the point in the lef tna d right image

%% Peaklist clean up

% do the closets peak calculation
dst=distance(pk',pk'); %#ok<NODEF>
diag_ix=sub2ind(size(dst),1:size(dst,1),1:size(dst,1));
dst(diag_ix)=Inf; % mark distance to itself as Inf to make sure its not the closest
mndst=min(dst,[],2); % the [],2) is to get it as a colum vector, its a symetric matrix anyway

% all the conditions in one find argument - gp:= good peaks
gp = pkint(:,3) < hpkh & ... left peak not to high
     pkint(:,3) > lpkh & ... left peak not to low
     pkint(:,4) < hpkh & ... right peak not to high
     pkint(:,4) > lpkh & ... right peak not to low
     pkint(:,2) > edgdist & ... not to close to upper edge
     pkint(:,1) > edgdist & ... not to close to left edge
     pkint(:,2) < imgsz(2)-edgdist & ... not to close to upper edge
     pkint(:,1) < imgsz(1)-edgdist & ... not to close to left edge
          mndst > pkdst; % no other peak within pkdst pixels away
 
pkgood=pk(gp,:);


