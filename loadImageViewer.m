keep rS
pth=[get(rS,'rootFolder') '\'];
filename=uigetfile([pth '*']);
md=MetaData([pth filename]);
img5d=readTiff(md,pth);
maxprj=cat(3,max(img5d(:,:,1,:,:),[],4),max(img5d(:,:,2,:,:),[],4));
showImg(md,pth,maxprj);
