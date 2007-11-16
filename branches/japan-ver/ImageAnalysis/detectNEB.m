function NEB=detectNEB(img,PlausiblyProphase,fig)

%% create filter if needed
fCellCutoffs=[0.01 0.05];
ordr=3;
persistent fCell;
if isempty(fCell)
    fprintf('creating a fCell filter in detectNEB\n');
    fCell=bandpassfilter(size(img),fCellCutoffs(1),fCellCutoffs(2),ordr);
end

%% preprocessing / filtering
ff=fft2(img);
fltCell=ifft2(fCell.*ff);
bw=im2bw(fltCell,graythresh(fltCell));
bw=imclearborder(bw);

%% create a new ROI based on old circle fits and find new cells in it
tileSize=256;
se=strel('disk',5);
nebTubIntRatio=1000;%0.95;

NEB=false(size(PlausiblyProphase,1),1);

oldCenters=PlausiblyProphase(:,1:2);

roi=[oldCenters(:,1)-tileSize/2 oldCenters(:,2)-tileSize/2 oldCenters(:,1)+tileSize/2 oldCenters(:,2)+tileSize/2];
roi=ceil(roi);
roi(:,1)=max(roi(:,1),1);
roi(:,2)=max(roi(:,2),1);
roi(:,3)=min(roi(:,3),size(img,2));
roi(:,4)=min(roi(:,4),size(img,1));
CircleFit=circleFitCells(bw,roi);

%% Assign new circle to old cells
oldRadi=PlausiblyProphase(:,3);
D=distance(oldCenters',CircleFit(:,1:2)');

[mn,mi]=min(D,[],2);
mi=mi(mn<oldRadi);
CircleFit=CircleFit(mi,:);

%% fit nucleus to all new cells 
rect=[1 1 1 1]; %#ok<NASGU>
Nuc=cell(size(CircleFit,1),1);
for i=1:size(CircleFit,1)
    rect=[CircleFit(i,1)-CircleFit(i,3) CircleFit(i,2)-CircleFit(i,3) 2*ones(1,2)*CircleFit(i,3)];
    rect(1:2)=max(1,rect(1:2));
    sml=imcrop(fltCell,rect);
    [Nuc{i},bw]=nucDetect(sml); %#ok<AGROW>
    cyto=logical(imdilate(bw,se)-bw);
    if isempty(Nuc{i}) || median(sml(bw))/median(sml(cyto)) > nebTubIntRatio
        NEB(i)=true;
    end
    for k=1:length(Nuc{i})
        bnd=Nuc{i}{k};
        Nuc{i}{k}(:,1)=bnd(:,2)+rect(1); %#ok<AGROW>
        Nuc{i}{k}(:,2)=bnd(:,1)+rect(2); %#ok<AGROW>
    end
end

plotCurrnetStatus('circles','nuclei')

%% nested function
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
                        plot(Nuc{jj}{kk}(:,1),Nuc{jj}{kk}(:,2),'g')
                    end
                end
            end
        end
        set(fig,'name','looking for NEB')
    end % of nested function plot...

%%
end % of main function

