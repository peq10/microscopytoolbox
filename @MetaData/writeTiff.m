function writeTiff(md,img)
% writeTiff to disk using md properties for filename 

[fullfilename,pth]=get(md,'fullfilename','path');

if ~exist(pth,'dir')
    mkdir(pth)
end

if length(md)>1
    warning('You supplied an array, using only the first MetaData object in it');  %#ok<WNTAG>
    md=md(1);
end

%% xml header
str=get(md,'xml');

%% figure out the number of tiff planes
dim=size(img);
plns=prod(dim)/dim(1)/dim(2);

%% reshape the image
img=reshape(img,[dim(1) dim(2) plns]);

%% write tiff
imwrite(img(:,:,1),fullfilename,'description',str);
for i=2:size(img,3)
    imwrite(img(:,:,i),fullfilename,'writemode','append');
end
