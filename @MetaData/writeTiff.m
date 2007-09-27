function writeTiff(md,img,pth)
% writeTiff to disk using md properties for filename 

filename=[pth get(md,'filename')];

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
imwrite(img(:,:,1),filename,'description',str);
for i=2:size(img,3)
    imwrite(img(:,:,i),filename,'writemode','append');
end
