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
ind=find(tbl(:,2)==2);
bwspindle=ismember(lbl,ind);   
pks2=pks(ismember(pks(:,3),ind),:);

lblspindle=bwlabel(bwspindle);
ix=sub2ind(size(lbl),pks2(:,1),pks2(:,2));
pks2(:,3)=lblspindle(ix);

%% score per cell
stat=regionprops(lblspindle,{'BoundingBox'});

for i=1:length(stat)
    sml(i).bbox=stat(i).BoundingBox;
    sml(i).gfp=imcrop(gfp,stat(i).BoundingBox); 
    sml(i).bw=imcrop(lblspindle==i,stat(i).BoundingBox);
    sml(i).pks=pks2(pks2(:,3)==i,1:2)-repmat(sml(i).bbox([1 2]),2,1);
%     sml(i).alpha=atan((sml(i).pks(1,2)-sml(i).pks(1,1))/(sml(i).pks(2,2)-sml(i).pks(2,1)));
%     sml(i).bwrot=imrotate(sml(i).bw,sml(i).alpha/pi*180,'crop');
%     sml(i).gfprot=imrotate(sml(i).gfp,sml(i).alpha/pi*180,'crop');
    b=bwboundaries(sml(i).bw);
    sml(i).SpindleBnd=b{1};
    sml(i).SpindleFit = fit_ellipse(b{1}(:,1),b{1}(:,2));
    if ~isempty(sml(i).SpindleFit)
        D=distance(sml(i).SpindleFit.xy',sml(i).SpindleBnd');
        sml(i).ScrSpindle=mean(min(D));
        a=min([sml(i).SpindleFit.a sml(i).SpindleFit.b]);
        b=max([sml(i).SpindleFit.a sml(i).SpindleFit.b]);
        sml(i).ratio=a/b;
    else
        sml(i).SpindleFit.xy=[NaN NaN];
        sml(i).ScrSpindle=Inf;
        sml(i).ration=NaN;
    end
end

%%
close all
figure(1)
imshow(gfp)
figure(2)
imshow(gfp2)
figure(3)
imshow(cat(3,bw,poles,zeros(size(bw))));
figure(4)
imshow(gfp3);
hold on
n=max(pks2(:,3));
clr=jet(n);
clr=clr(randperm(n),:);
for i=1:max(pks2(:,3))
    ix=find(pks2(:,3)==i);
    plot(pks2(ix,2),pks2(ix,1),'color',clr(i,:));
end
    
figure(5)
imshow(label2rgb(lblspindle,'jet','k','shuffle'));
hold on
plot(pks(:,2),pks(:,1),'.');
figure(6)
for i=1:40
    subplot(5,8,i)
    imshow(sml(i).gfp);
    hold on
    plot(sml(i).SpindleFit.xy(:,2),sml(i).SpindleFit.xy(:,1),'b');
%     plot(sml(i).pks(1,:),sml(i).pks(:,2));
    title(sprintf('ratio: %1.2f - scr: %1.2f',sml(i).ratio,sml(i).ScrSpindle));
end
