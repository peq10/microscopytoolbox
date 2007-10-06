function img=readTiff(md,pth)
% img=readTiff(md,pth) - a method of an MetaData object, get the filename from the md
% object and return the image. reads an multi-plane tiff file and returns an image. 
% It will reshape the img multi-D array acording to metadata 

%% check to see if md is a filename, if so create a MetaData object out of it
if ischar(md) && exist(fullfile(pth,[md '.tiff']),'file')
    md=MetaData(fullfile(pth,[md '.tiff']));
end

%% get the filename & check it
filename=fullfile(pth,[get(md,'filename') '.tiff']);

% checks to see that filename exists
if ~exist(filename,'file')
    error([filename 'does not exist, please check the MetaData object validity']);
end

%% get number of planes
tiffinfo=imfinfo(filename);
N=length(tiffinfo);

dim=get(md,'dimensionsize');

if N ~= prod(dim), error('Number of planes in file is different that expected by attribute DimensionSize, please check'); end

%% read image  - if compressed, uncompress it first using the private function ubcompressTiff
if ~strcmp(tiffinfo(1).Compression,'Uncompressed')
    uncompressTiff(filename);
    filename='tmp.tiff';
end

% Nedelec's version is faster that Matlab's (or should be, need to bench mark);
img=tiffread(filename);

%% trandform to 5D 
[ii,jj,kk]=ind2sub(dim,1:N);

imgT=zeros(size(img(1).data,1),size(img(1).data,2),max(ii),max(jj),max(kk));
for i=1:N
    imgT(:,:,ii(i),jj(i),kk(i))=mat2gray(img(i).data,[0 2^16]);
end

img=imgT;

