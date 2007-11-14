function NEB=detectNEB(img,PlausiblyProphase,fig)

%% segment the image
% fCent=bandpassfilter(size(img),fCentCutoffs(1),fCentCutoffs(2),ordr);
% fCell=bandpassfilter(size(img),fCellCutoffs(1),fCellCutoffs(2),ordr);
fCent=[]; %#ok<NASGU>
fCell=[];
load BandPassFilters

%% preprocessing / filtering
ff=fft2(img);
fltCell=ifft2(fCell.*ff);
bw=im2bw(fltCell,graythresh(fltCell));
bw=imclearborder(bw);

%% create a new ROI based on old circle fits and find new cells in it
tileSize=256;
se=strel('disk',5);
nebTubIntRatio=1000;%0.95;

NEB=zeros(length(PlausiblyProphase),1);

oldCenters=unique(PlausiblyProphase(:,1:2),'rows');

roi=[oldCenters(:,1)-tileSize/2 oldCenters(:,2)-tileSize/2 oldCenters(:,1)+tileSize/2 oldCenters(:,2)+tileSize/2];
roi=ceil(roi);
roi(:,1)=max(roi(:,1),1);
roi(:,2)=max(roi(:,2),1);
roi(:,3)=min(roi(:,3),size(img,2));
roi(:,4)=min(roi(:,4),size(img,1));
CircleFit=circleFitCells(bw,roi);

%% Assign new circle to old cells
[oldCenters,ix]=unique(PlausiblyProphase(:,1:2),'rows');
oldRadi=PlausiblyProphase(ix,5);
D=distance(oldCenters',CircleFit(:,1:2)');

[mn,mi]=min(D,[],2);
mi(mn>oldRadi)=NaN;

%% fit nucleus to all new cells 
rect=[1 1 1 1]; %#ok<NASGU>
for i=1:length(mi)
    if ~isnan(mi(i))
        ix=mi(i);
        rect=[CircleFit(ix,1)-CircleFit(ix,3) CircleFit(ix,2)-CircleFit(ix,3) 2*ones(1,2)*CircleFit(ix,3)];
        sml=imcrop(fltCell,rect);
        [Nuc{i},bw]=nucDetect(sml); %#ok<AGROW>
        
        cyto=logical(imdilate(bw,se)-bw);
        if isempty(Nuc{i}) || median(sml(bw))/median(sml(cyto)) > nebTubIntRatio
            NEB(i)=1;
        end
    end
end

plotCurrnetStatus('circles','nuclei')

    function plotCurrnetStatus(varargin)
        if exist('fig','var')
            figure(fig)
            hold on
            if sum(strcmp(varargin,'circles'))
                drawCircle(CircleFit)
            end
            hold on
            if sum(strcmp(varargin,'nuclei'))
                for jj=1:length(Nuc)
                    for kk=1:length(Nuc{jj})
                        plot(Nuc{jj}{kk}(:,1)+rect(1),Nuc{jj}{kk}(:,2)+rect(2),'g')
                    end
                end
            end
        end
    end % of nested function plot...

end

