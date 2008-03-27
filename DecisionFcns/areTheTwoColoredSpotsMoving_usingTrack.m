function [toSpawn,xtraData]=areTheTwoColoredSpotsMoving_usingTrack(img)

%% Define parameters:
lpkh=1000/2^16;  %min peak height
hpkh=16500/2^14;  %max peak height
pkdist=5;    %distance between peaks
edgdist=10;  %distance to edge
mindistance=2; %Minimun distance a spots has to move to be counted 
maxdistance=20; % Maximum distance (might help with matching outliers)
bps_param=[1,20]; % parameters for the bpass function
pkfnd_param=[0.1 1]; % parameter for the pkfnd function
track_param.mem=1;  %will skip up to one frames 
track_param.dim=2;  %
track_param.good=size(img,3)/2;  %discard traces if runs are shorter than half number of frames
track_param.quiet=1;  %turn off text

%% find peaks in both timepoints (why not find them in both colors separately?)

%TODO: change to the dual color thing 
% leftim=input(:,1:256);
% rightim(:,1:256)=input(:,257:512);
allpks=[];
for i=1:size(img,3)
    imgleft=img(1:512,:,i);
    imgright=img(513:end,:,i);
    pk=findGoodPeaks(imgleft,imgright,hpkh,lpkh,edgdist,pkdist,bps_param,pkfnd_param);
    allpks=[allpks; pk repmat(i,size(pk,1),1)];
end

if isempty(allpks)
    toSpawn = false;
    xtraData = [];
    return
end


%% Track the images in the movies so far
res = track(allpks,2,track_param);

spotno=max(res(:,4));
goodones=zeros(spotno,1);
for i=1:spotno
    dst=distance(res(res(:,4)==i,1:2)',res(res(:,4)==i,1:2)');
    if max(dst(:)) >mindistance
        % I'm doing maximum distance between any two timepoints
        % not just the first and last
        goodones(i)=1;  %make a note for a good spot
    end
end

%% find out if there is a point that after alignment 
toSpawn = sumsum(goodones) > 0;
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


