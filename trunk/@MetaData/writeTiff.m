function writeTiff(md,img,pth)
% writeTiff(md,img,pth)to disk using md properties for filename 

filename=[pth get(md,'filename') '.tiff'];

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
imwrite(uint16(img(:,:,1)*2^16),filename,'description',str);
for i=2:size(img,3)
    imwrite(unit16(img(:,:,i)*2^16),filename,'writemode','append');
end
