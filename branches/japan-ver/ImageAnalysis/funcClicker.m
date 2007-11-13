function [PlausiblyProphase,msg]=funcClicker(img,fig)

%% paramters
% used to create the freq filters
% fCentCutoffs=[0.075 0.1];
% fCellCutoffs=[0.01 0.05];
% ordr=3;

CentThresh=0.05;
minCentSize=4;
RadiusMultiply=1.5;

%% construct the filters
% fCent=bandpassfilter(size(img),fCentCutoffs(1),fCentCutoffs(2),ordr);
% fCell=bandpassfilter(size(img),fCellCutoffs(1),fCellCutoffs(2),ordr);
load BandPassFilters

%% preprocessing / filtering
ff=fft2(img);
fltCent=ifft2(fCent.*ff);
fltCell=ifft2(fCell.*ff);

msg='found';

%% thresholg segmentation for cells and centrosomes
bw=im2bw(fltCell,graythresh(fltCell));
bw=imclearborder(bw);
Cent=im2bw(fltCent,CentThresh);
Cent=bwareaopen(Cent,minCentSize);
Cent(~bw)=0;
centstt=regionprops(bwlabel(Cent),'centroid');
xycent=reshape([centstt.Centroid]',2,length(centstt))';

% check if found any centrosomes
if isempty(xycent)
    PlausiblyProphase=[];
    msg='no centrosomes found';
    return
end

%% Fit circles in roi
tileSize=256;
roi=[xycent(:,1)-tileSize/2 xycent(:,2)-tileSize/2 xycent(:,1)+tileSize/2 xycent(:,2)+tileSize/2];
roi=ceil(roi);
roi(:,1)=max(roi(:,1),1);
roi(:,2)=max(roi(:,2),1);
roi(:,3)=min(roi(:,3),size(img,2));
roi(:,4)=min(roi(:,4),size(img,1));
CircleFit=circleFitCells(bw,roi);

%% allocate centrosomes to circles

% First get rid of all centrosomes that have multiple ownerships
Dmult=distance(xycent(:,[1 2])',CircleFit(:,1:2)');
ix=find((sum(Dmult<repmat(CircleFit(:,3)'*RadiusMultiply,size(Dmult,1),1),2)==1));
xycent=xycent(ix,:); %#ok

% now assign nearest neighbor of cirle to each centrosome
D=distance(xycent',CircleFit(:,1:2)');
[bla,mi]=min(D,[],2); %#ok
PlausiblyProphase=[ CircleFit(mi,:) xycent];

if isempty(PlausiblyProphase)
    msg='centrosmes dont belong to any cell';
    return
end

%% Fit nucleus only to the Plausible cells
Nuc=[];
CellsToCheck=unique(mi);
for j=1:length(CellsToCheck)
    ix=CellsToCheck(j);
    rect=[CircleFit(ix,1)-CircleFit(ix,3) CircleFit(ix,2)-CircleFit(ix,3) 2*ones(1,2)*CircleFit(ix,3)];
    sml=imcrop(fltCell,rect);
    Nuc{j}=nucDetect(sml);
    nucNum(j)=length(Nuc{j}); %#ok
    for k=1:length(Nuc{j})
        bnd=Nuc{j}{k};
        Nuc{j}{k}(:,1)=bnd(:,2)+CircleFit(j,1)-CircleFit(j,3);
        Nuc{j}{k}(:,2)=bnd(:,1)+CircleFit(j,2)-CircleFit(j,3);
    end
end

%%  keep only cells with single nucleus 
PlausiblyProphase=PlausiblyProphase(ismember(mi,find(nucNum==1)),:);
[bla,ix]=unique(PlausiblyProphase(:,1:2),'rows'); %#ok
PlausiblyProphase=PlausiblyProphase(ix,:);

if isempty(ix)
    msg='all cells  are multi nucleate';
    return
end

%% plotting
if exist('fig','var')
    figure(fig)
    hold on
    drawCircle(CircleFit)
    hold on
    plot(xycent(:,1),xycent(:,2),'.r')
    for j=1:length(Nuc)
        for k=1:length(Nuc{j})
            plot(Nuc{j}{k}(:,1),Nuc{j}{k}(:,2),'g')
        end
    end
end

% ginput(1);


