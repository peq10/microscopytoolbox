function plotImage(rS)

img=get(rS,'lastImage');

clf
subplot('position',[0 0 1 1])
if size(img,3) ==2
    img=cat(3,img,zeros(size(img(:,:,1))));
elseif size(img,3) > 3
    img=img(:,:,1);
end

imshow(img,'DisplayRange',[],'initialmagnification','fit')

        