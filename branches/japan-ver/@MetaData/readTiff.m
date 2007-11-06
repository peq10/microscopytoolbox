function img=readTiff(md,pth,varargin)
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
ordr=get(md,'dimensionorder');
Tdim=find(ordr=='T');
Zdim=find(ordr=='Z');

if N ~= prod(dim), error('Number of planes in file is different that expected by attribute DimensionSize, please check'); end

%% If no projection or timeslice - read all in fast way
if isempty(varargin)
    % Nedelec's version is faster that Matlab's (or should be, need to bench mark);
    img=tiffread(filename);

    %% trandform to 5D
    [ii,jj,kk]=ind2sub(dim,1:N);
    sz=[size(img(1).data) max(ii),max(jj),max(kk)];
    img=single(reshape([img.data],sz))./2^16;
    return
end


%% get the additionl options
planeTimes=1:dim(Tdim-2);
projectZ=0;
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'zprojection'
            projectZ=1;
            projectionType=varargin{i+1};
        case 'timeslice'
            switch varargin{i+1}
                case 'first'
                    planeTimes=1;
                case 'last'
                    planeTimes=dim(Tdim-2);
                case 'all'
                    planeTimes=1:dim(Tdim-2);
                otherwise
                    if ~isnumeric(varargin{i+1}) 
                        error('Timeslice can be either all {default}/first last or numeric array with timepoint indexes');
                    end
                    planeTimes=intersect(varargin{i+1},planeTimes);
            end
        otherwise
            warning('unsupported property for readTiff'); %#ok<WNTAG>
    end
end


%% read image  - if compressed, uncompress it first using the private function ubcompressTiff
if ~strcmp(tiffinfo(1).Compression,'Uncompressed')
    uncompressTiff(filename);
    filename='tmp.tiff';
end

img=single([]);

%% read according to timeslices
for t=planeTimes
    % find the linear index to read
    if Tdim==3
        [sb1,sb2,sb3]=meshgrid(t,1:dim(2),1:dim(3));
        planeIxs=sub2ind(dim,sb1(:),sb2(:),sb3(:));
    elseif Tdim==4
        [sb1,sb2,sb3]=meshgrid(1:dim(1),t,1:dim(3));
        planeIxs=sub2ind(dim,sb1(:),sb2(:),sb3(:));
    elseif Tdim==5
        [sb1,sb2,sb3]=meshgrid(1:dim(1),1:dim(2),t);
        planeIxs=sub2ind(dim,sb1(:),sb2(:),sb3(:));
    else
        error('dim order doesn:t make sense - check it out')
    end
    % read it
    timepointimg=single(zeros(tiffinfo(1).Height,tiffinfo(1).Width,length(planeIxs)));
    for i=1:length(planeIxs)
        plane=tiffread(filename,planeIxs(i));
        timepointimg(:,:,i)=single(plane.data); 
    end
    
    % permute the img to 5D
    timepointdim=dim;
    timepointdim(Tdim-2)=1;
    
    %% transform to 5D
    [ii,jj,kk]=ind2sub(timepointdim,1:length(planeIxs));

    timepointimgT=single(zeros(size(timepointimg,1),size(timepointimg,2),max(ii),max(jj),max(kk)));
    for i=1:length(planeIxs)
        timepointimgT(:,:,ii(i),jj(i),kk(i))=timepointimg(:,:,i);
    end
    clear timepointimg;

    % do projection if necessary
    if projectZ
        switch projectionType
            case 'mean'
                timepointimgT=mean(timepointimgT,Zdim);
            case 'max'
                timepointimgT=max(timepointimgT,[],Zdim);
            case 'none'
            otherwise
                error('Unsupported projection type')
        end
    end
    % combine it with img
    img=cat(Tdim,img,timepointimgT);
    clear timepointimgT
end

%% resacle img to 0-1
img=img/2^16;
