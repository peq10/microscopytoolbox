function showadj(img,lvl)
if ~exist('lvl','var')
    lvl=[0 99.9];
end
imshow(img,prctile(img(:),lvl))