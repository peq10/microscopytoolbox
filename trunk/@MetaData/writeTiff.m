function writeTiff(md,img,pth)
% writeTiff : write an image (img) to disk based on the md object
%   The final filename would be relative to the path pth. 
%   Images are saved as 16 bit tiffs of the III format, e.g. all the
%   metadata information is saved in the first plane description tag. 
%   if a filename already exist, it will APPEND the image to the end and 
%   merge the metadata using the merge method. 
%
%   example: 
%           md=MetaData('myfilename');
%           img=acqImg(rS); 
%           writeTiff(md,img,get(rS,'rootFolder'));


%% check if its more then one MetaData element
if length(md)>1
    warning('You supplied an array, using only the first MetaData object in it');  %#ok<WNTAG>
    md=md(1);
end

%% get the filename and check if need to add .tff
filename=fullfile(pth,get(md,'filename'));
[p,f,ext]=fileparts(filename);
if ~ismember(ext,{'.tif','.tiff'})
    filename=[filename '.tiff'];
end

%% check to see if file exist - if so concatenates the MetaData objects
if exist(filename,'file')
    meta(1)=get(md,'metadata');
    meta(2)=MetaData(filename);
    md=concat(meta([2 1]));
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