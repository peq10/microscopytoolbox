function img=readTiff(md)
% readTiff - a method of an MetaData object, get the filename from the md
% object and reads it 
% reads an OME-tiff file and returns an image and meta-data structure.
% It will reshape the img multi-D array acording to metadata 
%
% This is done with a few steps: 
% 1. get tiff header 2. parse xml 3. get img atr 4. get img 5.trans img. 
% 
% depends on package xmltree 

%% get the filename & check it
filename=get(md,'fullfilename');

% checks to see that filename exists
if ~exist(filename,'file')
    error([filename 'does not exist, please check the MetaData object validity']);
end

%% get Image sizes attributes 
[SizeX,SizeY,SizeZ,SizeT,SizeC,dimensionOrder]=get(md,'SizeX','SizeY','SizeZ','SizeT','SizeC','dimension_order');

%% validate that the number of planes is appropriate - only warnings...
Nexist=length(info); 
Nneeded=SizeZ*SizeT*SizeC;

if Nexist>Nneeded
    warning(['Image has MORE planes then defnined in metadata - discarding ' num2str(Nexist-Nneeded) ' planes']) %#ok
    N=Nneeded;
elseif Nexist<Nneeded
    warning(['Image has LESS planes then defnined in metadata - missing ' num2str(Nneeded-Nexist) ' planes'])  %#ok 
    N=Nexist;
else
    N=Nneeded;
end

% To allow creating large stack from images, Init says at what plane to
% start. 
Init=1;


%% get all image planes
fprintf('\n');
img=zeros(SizeX,SizeY,N-Init+1);
for i=Init:(N)
    img(:,:,i-Init+1)=imread(filename,i);
    fprintf('.');
end
fprintf('\n');
        

%% Transform dimensionality 
 
switch dimensionOrder
    case 'XYZTC'
        dim=[SizeZ SizeT SizeC];
    case 'XYZCT'
        dim=[SizeZ SizeC SizeT];
    case 'XYCTZ'
        dim=[SizeC SizeT SizeZ];
    case 'XYCZT'
        dim=[SizeC SizeZ SizeT];
    case 'XYTCZ'
        dim=[SizeT SizeC SizeZ];
    case 'XYTZC'
        dim=[SizeT SizeZ SizeC];
    otherwise
        error('Pixels DimensionOrder is invalid, check the xml header of this OME-tiff');
end

[ii,jj,kk]=ind2sub(dim,1:N);

imgT=zeros(size(img,1),size(img,2),max(ii),max(jj),max(kk));
for i=1:N
    imgT(:,:,ii(i),jj(i),kk(i))=img(:,:,i);
end



