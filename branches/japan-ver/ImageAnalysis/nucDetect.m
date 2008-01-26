function [Nuc,smlbw]=nucDetect(sml,filterFlag)
% find all nuclei within a sml image (which should be in the order of cell
% size)

%% parameters
fCentCutoffs=[0.075 0.1];
fCellCutoffs=[0.01 0.05];
ordr=3;

%% check if need to filter image
if ~exist('filterFlag','var')
    filterFlag=0;
end

if filterFlag
    fCell=bandpassfilter(size(sml),fCellCutoffs(1),fCellCutoffs(2),ordr);
    ff=fft2(fCell);
    sml=ifft2(fCell.*ff);
end

%% do the nuclear fitting
 figure
 sml=mat2gray(-sml);
 nucPeak=0.05;
 smlbw=zeros(size(sml));
 smlbwtst=imclearborder(imextendedmax(sml,nucPeak));
 chngFlag=1;
 cnt=2;
 subplot(2,3,1), imshow(sml)
 subplot(2,3,cnt), imshow(smlbwtst)
 while chngFlag && max(smlbwtst(:))
     smlbw=smlbwtst;
     nucPeak=nucPeak+0.05;
     smlbwtst=imclearborder(imextendedmax(sml,nucPeak));
     cnt=cnt+1;
     subplot(2,3,cnt), imshow(smlbwtst)
     if sum(smlbw(:)==smlbwtst(:))==numel(sml)
         chngFlag=0;
     end
 end
 Nuc=bwboundaries(smlbw);