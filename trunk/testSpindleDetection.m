% function sml=testSpindleDetection(img,plotFlag)
% finds cells and does some measurements on them
% all is returned as a struct with lots of analysis steps and scores per
% spindle
% 
% if nargin==1
%     plotFlag=0;
% end

%% params
noiseSuppress=0.1;
poleSuppress=0.075;
lowThrshBW=1.5; % multiple this by the graythresh results
lowThrshSpindle=100;

f=fspecial('disk',3);

MinArea=500;
MaxArea=15000;

%% initial segmentation
gfp=mat2gray(medfilt2(img));
gfp2=imhmax(gfp,noiseSuppress);
bw=im2bw(gfp2,min(graythresh(gfp2)*lowThrshBW,1));
bw=bwareaopen(bw,MinArea);
bw=bw-bwareaopen(bw,MaxArea);
bw=imclearborder(bw);
lbl=bwlabel(bw);
gfp3=gfp; gfp3(~bw)=min(gfp(:));
poles=imextendedmax(gfp3,poleSuppress);
[pks(:,1) pks(:,2)]=find(bwmorph(poles,'shrink',Inf));
ix=sub2ind(size(lbl),pks(:,1),pks(:,2));
pks(:,3)=lbl(ix);
tbl=tabulate(pks(:,3));
bwspindle=ismember(lbl,find(tbl(:,2)==2));   
lblspindle=bwlabel(bwspindle);


%
figure(1)
imshow(gfp)
figure(2)
imshow(gfp2)
figure(3)
imshow(cat(3,bw,poles,zeros(size(bw))));
figure(4)
imshow(gfp3);
hold on
plot(pks(:,2),pks(:,1),'.');
figure(5)
imshow(label2rgb(lblspindle,'jet','k','shuffle'));
hold on
plot(pks(:,2),pks(:,1),'.');

lbl_old=lbl;
lbl=lblspindle;

%% score per cell
stat=regionprops(lbl,{'centroid','BoundingBox','EquivDiameter','Area'});
for i=1:length(stat)
    sml(i).thrsh=graythresh(gfp(lbl==i));%#ok
    sml(i).bbox=stat(i).BoundingBox;
    sml(i).gfp=imcrop(gfp,stat(i).BoundingBox); 
    sml(i).bw=imcrop(bw,stat(i).BoundingBox);
    %% score for round BW
    cntr=round(size(sml(i).bw)/2);
 
%  find a best fitting circle for cell background   
%     sml(i).circle=circlepoints(cntr(2),cntr(1),round(stat(i).EquivDiameter/2));
%     b=bwboundaries(sml(i).bw);
%     sml(i).CircleBnd=b{1};
%     D=distance(sml(i).CircleBnd',sml(i).circle');
%     sml(i).ScrRnd=mean(min(D));
    
    %% create the forground image
    ix=find(sml(i).bw);
    ix2=find(sml(i).gfp(ix)<sml(i).thrsh*lowThrshSpindle);
    sml(i).fg=sml(i).gfp;
    sml(i).fg(~sml(i).bw)=min(sml(i).gfp(:));
    sml(i).fg(ix(ix2))=min(sml(i).gfp(:)); %#ok
    sml(i).fg=imadjust(sml(i).fg);
    sml(i).fgsupressed=imhmax(imfilter(sml(i).gfp,f),poleSuppress);
    sml(i).poles=imregionalmax(sml(i).fgsupressed);
    [ii,jj]=find(bwmorph(sml(i).poles,'shrink',Inf));
    sml(i).pks=[ii jj];
    sml(i).poleNum=length(ii);
    % if there are only two peaks - rotate the image
    if size(sml(i).pks,1)==2;
        sml(i).alpha=atan((ii(2)-ii(1))/(jj(2)-jj(1)));
        
%         sml(i).alpha=0;
        
        
        sml(i).rot=imrotate(sml(i).fg,sml(i).alpha/pi*180,'crop');
        b=bwboundaries(sml(i).rot>0);
        sml(i).SpindleBnd=b{1};
        sml(i).SpindleFit = fit_ellipse(b{1}(:,1),b{1}(:,2));
        if ~isempty(sml(i).SpindleFit)
            D=distance(sml(i).SpindleFit.xy',sml(i).circle');
            sml(i).ScrSpindle=mean(min(D));
        else
            sml(i).SpindleFit.xy=[NaN NaN];
            sml(i).ScrSpindle=Inf;
        end
    else
        sml(i).SpindleBnd=[NaN NaN];
        sml(i).rot=0;
        sml(i).alpha=0;
        sml(i).SpindleFit.xy=[NaN NaN];
        sml(i).ScrSpindle=Inf;
    end
end

%% plotting if required
% if ~plotFlag
%     return
% end
figure(6), imshow(gfp);
% hold on
% clr=jet(length(sml));
% clr=clr(randperm(length(sml)),:);
% for i=1:length(sml)
%     pks=sml(i).pks+repmat(sml(i).bbox([2 1]),sml(i).poleNum,1);
%     elps=sml(i).SpindleFit.xy+repmat(sml(i).bbox([2 1]),size(sml(i).SpindleFit.xy,1),1);
%     plot(pks(:,2),pks(:,1),'x','color',clr(i,:));
%     plot(elps(:,2),elps(:,1),':w')
% end

n=min(10,length(sml));


for i=1:n
    subplot(n,4,1+(i-1)*4)
    imshow(sml(i).gfp,[])
    subplot(n,4,2+(i-1)*4)
    imshow(sml(i).fg,[])
    hold on
    plot(sml(i).circle(:,2),sml(i).circle(:,1),'r.')
    plot(sml(i).CircleBnd(:,2),sml(i).CircleBnd(:,1),'g')
    subplot(n,4,3+(i-1)*4)
    imshow(sml(i).poles,[])
    hold on
    plot(sml(i).pks(:,2),sml(i).pks(:,1),'.');
    colormap jet
    subplot(n,4,4+(i-1)*4)
    imshow(sml(i).rot,[]);
    hold on
    plot(sml(i).SpindleBnd(:,2),sml(i).SpindleBnd(:,1),'g')
    plot(sml(i).SpindleFit.xy(:,2),sml(i).SpindleFit.xy(:,1),'r')
end
