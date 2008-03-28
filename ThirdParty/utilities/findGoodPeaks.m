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
     pkint(:,2) < imgsz(1)-edgdist & ... not to close to upper edge
     pkint(:,1) < imgsz(2)-edgdist & ... not to close to left edge
          mndst > pkdst; % no other peak within pkdst pixels away
 
pkgood=pk(gp,:);


