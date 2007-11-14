function [PlausiblyProphase,msg]=funcClicker(img,fig)

%% paramters
% used to create the freq filters
% fCentCutoffs=[0.075 0.1];
% fCellCutoffs=[0.01 0.05];
% ordr=3;

CentThresh=0.0125;
minCentSize=4;
RadiusMultiply=1.5;
CentProxToCircleCenter=0.75;   

%% construct the filters
% fCent=bandpassfilter(size(img),fCentCutoffs(1),fCentCutoffs(2),ordr);
% fCell=bandpassfilter(size(img),fCellCutoffs(1),fCellCutoffs(2),ordr);
fCent=[];
fCell=[];
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
    plotCurrnetStatus;
    drawnow
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

if isempty(CircleFit)
    PlausiblyProphase=[];
    msg='no Cells found';
    plotCurrnetStatus('centrosomes');
    drawnow
    return
end

%% allocate centrosomes to circles

% First get rid of all centrosomes that have multiple ownerships
Dmult=distance(xycent(:,[1 2])',CircleFit(:,1:2)');
ix=find((sum(Dmult<repmat(CircleFit(:,3)'*RadiusMultiply,size(Dmult,1),1),2)==1));

if isempty(ix)
    PlausiblyProphase=[];
    msg='centrosmes ownership ambigues';
    plotCurrnetStatus('centrosomes','circles');
    drawnow
    return
end

% if ix is not empty - remove all the 
xycent=xycent(ix,:); %#ok

% now assign ownership to each centrome - given that it is close to the
% center by a CentProxToCircleCenter factor
D=distance(xycent',CircleFit(:,1:2)');
[dst,mi]=min(D,[],2); 
PlausiblyProphase=[CircleFit(mi,:) xycent];
% keep only the ones that the closet centrosome is less that
% CentProxToCircleCenter * Circle radius
ix=find(dst<PlausiblyProphase(:,3)*CentProxToCircleCenter);
PlausiblyProphase=PlausiblyProphase(ix,:);
mi=mi(ix);
if isempty(PlausiblyProphase)
    msg='centrosmes to far from cell center';
    plotCurrnetStatus('centrosomes','circles');
    drawnow
    return
end

plotCurrnetStatus('centrosomes','circles');

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
    plotCurrnetStatus('centrosomes','circles','nuclei');
    drawnow
    return
end

plotCurrnetStatus('centrosomes','circles','nuclei');
drawnow

%% plotting
    function plotCurrnetStatus(varargin)
        if exist('fig','var')
            figure(fig)
            hold on
            if sum(strcmp(varargin,'circles'))
                drawCircle(CircleFit)
            end
            hold on
            if sum(strcmp(varargin,'centrosomes'))
                plot(xycent(:,1),xycent(:,2),'.r')
            end
            if sum(strcmp(varargin,'nuclei'))
                for jj=1:length(Nuc) 
                    for kk=1:length(Nuc{jj}) 
                        plot(Nuc{jj}{kk}(:,1),Nuc{jj}{kk}(:,2),'g')
                    end
                end
            end
        end
        set(fig,'name',msg);
    end % of nested function plot...

%%
end % main function 
% ginput(1);


