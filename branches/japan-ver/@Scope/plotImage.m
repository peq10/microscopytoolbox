function plotImage(rS)

img=get(rS,'lastImage');

clf
subplot('position',[0 0 1 1])
imshow(img(:,:,1),'DisplayRange',[],'initialmagnification','fit')