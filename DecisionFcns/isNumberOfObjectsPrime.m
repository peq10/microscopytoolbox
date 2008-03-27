function [toSpawn,xtraData]=isNumberOfObjectsPrime(img)
% an example function for a decision function that returns
% true if the number of objects 

%% do the image analysis
thrsh=graythresh(img(:,:,1));
bw=im2bw(img,thrsh);
[lb,n]=bwlabel(bw);

%% prepare output
toSpawn=isprime(n);
xtraData=factor(n);
