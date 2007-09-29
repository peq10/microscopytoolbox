function img=readTiff(md,pth)
% readTiff - a method of an MetaData object, get the filename from the md
% object and reads it 
% reads an multi-plane tiff file and returns an image checks if img
% meta-data structure is the same is input object md
% It will reshape the img multi-D array acording to metadata 
%
% This is done with a few steps: 
% 1. get tiff header 2. parse xml 3. get img atr 4. get img 5.trans img. 
% 

%% get the filename & check it
filename=[pth get(md,'filename') '.tiff'];

% checks to see that filename exists
if ~exist(filename,'file')
    error([filename 'does not exist, please check the MetaData object validity']);
end

% % checks to file metadata is equal to MD
% md_fromfile=MetaData(filename);
% md_frommd=MetaData(md);
% if ~isequal(md_fromfile,md)
%     error(['MetaData in file is different from suppleid MD object\n'...
%              'If you changed somthing in MD, please update the file using updateTiffMetaData first']);
% end
% clear md_fromfile;

%% get number of planes
tiffinfo=imfinfo(filename);
N=length(tiffinfo);

dim=get(md,'dimensionsize');

if N ~= prod(dim), error('Number of planes in file is different that expected by attribute DimensionSize, please check'); end

%% read image
fprintf('\n');
% img=zeros(SizeX,SizeY,N-Init+1);
for i=1:(N)
    img(:,:,i)=mat2gray(imread(filename,i),[0 2^16]);
    fprintf('\b\b\b\b%04i',i);
end
fprintf('\n');

% Nedelec's version is faster that Matlab's (or should be...);
% img=tiffread(filename);

%% trandform to 5D if needed
[ii,jj,kk]=ind2sub(dim,1:N);

imgT=zeros(size(img,1),size(img,2),max(ii),max(jj),max(kk));
for i=1:N
    imgT(:,:,ii(i),jj(i),kk(i))=img(:,:,i);
end

img=imgT;

