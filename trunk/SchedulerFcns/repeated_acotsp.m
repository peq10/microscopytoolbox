function ordr = repeated_acotsp(x,y,t,id,x_current,y_current,tasks_duration,t_current)
% assumes that I need to go in circles

%% sort them all based on time & divinde into blocks
xy=[x y];
[xyunq,bla,ix]=unique(xy,'rows');
tunq=unique(t); 
tic
blockOrdr=acotsp(xyunq(:,1),xyunq(:,2),nan(size(xyunq(:,1))),(1:size(xyunq,1))',x_current,y_current);
%%
xyunq=xyunq(blockOrdr,:);
tic
ordr=zeros(size(id));
cnt=0;
for j=1:length(tunq)
    for i=1:size(xyunq,1)
        cnt=cnt+1;
        ordr(cnt)=id(find((x==xyunq(i,1)).*(y==xyunq(i,2)).*(t==tunq(j))));
    end
end
toc            
%%
% % [tsrt,ix]=sort(t);
% % xsrt=x(ix);
% % ysrt=y(ix);
% % id_srt=id(ix);
% % 
% % % divide into blocks
% % strt_ix=find((xsrt==xsrt(1)).*(ysrt==ysrt(1)));
% % strt_ix=[strt_ix; length(x)+1];
% 
% for i=2:length(strt_ix)
%     Xblock(:,i-1)=xsrt(strt_ix(i-1):(strt_ix(i)-1));
%     Yblock(:,i-1)=ysrt(strt_ix(i-1):(strt_ix(i)-1));
%     Tblock(:,i-1)=tsrt(strt_ix(i-1):(strt_ix(i)-1));
%     IDblock(:,i-1)=id_srt(strt_ix(i-1):(strt_ix(i)-1));
% end
% 
% %% find order of first block
% blockOrdr=acotsp(Xblock(:,1),Yblock(:,1),Tblock(:,1),(1:size(IDblock,1))',x_current,y_current);
% 
% ordr=[];
% for i=1:size(IDblock,2)
%     ordr=[ordr; IDblock(blockOrdr,i)];
% end

