function writeTiff(md,img,pth)
% writeTiff(md,img,pth)to disk using md properties for filename 

filename=fullfile(pth,[get(md,'filename') '.tiff']);

if length(md)>1
    warning('You supplied an array, using only the first MetaData object in it');  %#ok<WNTAG>
    md=md(1);
end

%% check to see if file exist - if so merges the MetaData objects
if exist(filename,'file')
    meta(1)=get(md,'metadata');
    meta(2)=MetaData(filename);
    md=merge(meta([2 1]));
end

%% figure out the number of tiff planes
dim=size(img);
plns=prod(dim)/dim(1)/dim(2);

%% reshape the image
img=reshape(img,[dim(1) dim(2) plns]);

%% write tiff
for i=1:size(img,3)
    imwrite(uint16(gray2ind(img(:,:,i),2^16)),filename,'writemode','append','compression','none');
end

%% update its metadata
updateTiffMetaData( md,pth )