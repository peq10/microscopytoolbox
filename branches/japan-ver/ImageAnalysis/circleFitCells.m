function CircleFit=circleFitCells(bw,roi)
% circleFitCells fit circles around cells

if exist('roi','var')
    msk=zeros(size(bw));
    for i=1:size(roi,1)
        msk(roi(i,2):roi(i,4),roi(i,1):roi(i,3))=1;
    end
    bw=bw.*msk;
    bw=(bw==1);
end

%% parameters
se=strel('disk',20);
minPeakSize=0.5;

maxSingleCellSize=10000;
maxMultiCellSize=10000;
MinAxisRationForSplot=0.75;

MergeDistance=50;

features={'ConvexArea','ConvexHull','ConvexImage',...
    'BoundingBox','MajorAxisLength','MinorAxisLength',...
    'FilledImage','Image','PixelIdxList'};


%% convex close of an image
[lbl,n]=bwlabel(bw);
stt=regionprops(lbl,features);

cnv=zeros(size(bw));
for j=1:n
    idy=ceil(stt(j).BoundingBox(1)+(1:stt(j).BoundingBox(3)));
    idx=ceil(stt(j).BoundingBox(2)+(1:stt(j).BoundingBox(4)));
    cnv(idx,idy)=stt(j).ConvexImage;
end
cnv=imresize(cnv,size(bw))>0;
cls=imclose(bw,se);
clscnv=cls.*cnv;
lbl=bwlabel(clscnv);
stt=regionprops(lbl,features);


%% split things that are too big
cnvarea=[stt.ConvexArea]';
axsratio=[stt.MinorAxisLength]'./[stt.MajorAxisLength]';

ix=find((cnvarea>maxSingleCellSize).*(axsratio<MinAxisRationForSplot)+(cnvarea>maxMultiCellSize));

for j=1:length(ix)
    sml=stt(ix(j)).FilledImage;
    dst=bwdist(~sml);
    dst=-dst;
    dst(~sml)=-Inf;
    dst=imhmin(dst,minPeakSize);
    wtrshd=watershed(dst);
    sml=(wtrshd>1).*stt(ix(j)).Image;
    idy=ceil(stt(ix(j)).BoundingBox(1)+(1:stt(ix(j)).BoundingBox(3)));
    idx=ceil(stt(ix(j)).BoundingBox(2)+(1:stt(ix(j)).BoundingBox(4)));
    clscnv(idx,idy)=sml;
end

%% after watershed discard of too big and circular

[lbl,n]=bwlabel(clscnv);
stt=regionprops(lbl,features);
cnvarea=[stt.ConvexArea]';
axsratio=[stt.MinorAxisLength]'./[stt.MajorAxisLength]';

% disctriminate by size and axis ratio
ix=find((cnvarea>maxSingleCellSize).*(axsratio<MinAxisRationForSplot)+(cnvarea>maxMultiCellSize));
ix=setdiff(1:n,ix);
stt=stt(ix);

%% Cluster circles togather
for j=1:length(stt),
    [center,radius] = minboundcircle(stt(j).ConvexHull(:,1),stt(j).ConvexHull(:,2));
    crcle(j,:)=[center radius];
end

if isempty(stt)
    CircleFit=[];
    return
end

D=pdist(crcle(:,1:2));
Z=linkage(D,'average');
C=cluster(Z,'cutoff',MergeDistance,'criterion','distance');

lbl=zeros(size(bw));
for j=1:length(ix);
    lbl(stt(j).PixelIdxList)=C(j);
end

CircleFit=[];

stt=regionprops(lbl,features);
for j=1:length(stt),
    [center,radius] = minboundcircle(stt(j).ConvexHull(:,1),stt(j).ConvexHull(:,2));
    if ~isempty(center)
        CircleFit(j,:)=[center radius];
    else
        CircleFit(j,:)=[Inf Inf 0];
    end
end
CircleFit=CircleFit((CircleFit(:,3)>25) & (CircleFit(:,3)<75),:);