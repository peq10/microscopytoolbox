function [PlausiblyProphase,msg]=funcClicker(img,param,fig)

%% paramters
% used to create the freq filters
fCellCutoffs=[0.01 0.05];
fCentCutoffs=[0.075 0.1];

ordr=3;

CentThresh=param;

minCentSize=4;
RadiusMultiply=1.5;
CentProxToCircleCenter=0.75;   


%% construct the filters
persistent fCent;
if isempty(fCent)
    fprintf('creating a fCent filter in funcClicker\n');
    fCent=bandpassfilter(size(img),fCentCutoffs(1),fCentCutoffs(2),ordr);
end
persistent fCell;
if isempty(fCell)
    fprintf('creating a fCell filter in funcClicker\n');
    fCell=bandpassfilter(size(img),fCellCutoffs(1),fCellCutoffs(2),ordr);
end

%% preprocessing / filtering
ff=fft2(img);
fltCent=ifft2(fCent.*ff);
fltCell=ifft2(fCell.*ff);

msg='found';

%% thresholg segmentation for cells and centrosomes
bw=im2bw(fltCell,graythresh(fltCell));
bw=imclearborder(bw);

% determine the threshold based on cell border
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

% here we ahave a row per centrosome
PlausiblyProphase=[CircleFit(mi,:) xycent];

% keep only the ones that the closet centrosome is less that
% CentProxToCircleCenter * Circle radius
ix=find(dst<PlausiblyProphase(:,3)*CentProxToCircleCenter);
PlausiblyProphase=PlausiblyProphase(ix,:); %#ok<FNDSB>


if isempty(PlausiblyProphase)
    msg='centrosmes to far from cell center';
    plotCurrnetStatus('centrosomes','circles');
    drawnow
    return
end

% moving into a row per cell
[bla,ix]=unique(PlausiblyProphase(:,1:2),'rows'); %#ok
PlausiblyProphase=PlausiblyProphase(ix,:);

%% Fit nucleus only to the Plausible cells
Nuc=[];
for j=1:size(PlausiblyProphase,1)
    rect=[PlausiblyProphase(j,1)-PlausiblyProphase(j,3) PlausiblyProphase(j,2)-PlausiblyProphase(j,3) 2*ones(1,2)*PlausiblyProphase(j,3)];
    rect(1:2)=max(1,rect(1:2));
    sml=imcrop(fltCell,rect);
    Nuc{j}=nucDetect(sml);
    nucNum(j)=length(Nuc{j}); %#ok
    for k=1:length(Nuc{j})
        bnd=Nuc{j}{k};
        Nuc{j}{k}(:,1)=bnd(:,2)+rect(1);
        Nuc{j}{k}(:,2)=bnd(:,1)+rect(2);
    end
end

%%  keep only cells with single nucleus 
PlausiblyProphase=PlausiblyProphase(nucNum==1,:);

if isempty(PlausiblyProphase)
    msg='Could not assign only a single nuclei';
    plotCurrnetStatus('centrosomes','circles','nuclei');
    drawnow
    return
end

plotCurrnetStatus('centrosomes','circles','nuclei');
drawnow

%% plotting
    function plotCurrnetStatus(varargin)
        if exist('fig','var') && ~isempty(fig) && fig>0
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
            set(fig,'name',msg);
        end
    end % of nested function plot...

%%
end % main function 
% ginput(1);


