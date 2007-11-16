function plotTaskStatusByType(rS)

Tsks=getTasks(rS,'all');
[fncStr,status]=get(Tsks,'fcnstr','status');

unqStt=unique(status);

[unq,bla,m]=unique(fncStr);
tbl=tabulate(m);

stts=zeros(size(tbl,1),2);

for i=1:size(tbl,1)
    for j=1:length(unqStt)
        stts(i,j)=sum(strcmp(status,unqStt{j}));
    end
end
    
barh(stts,'stacked')
set(gca,'yticklabel',unq,'ylim',[0.5 size(tbl,1)+0.5]);
xlabel('Number of Tasks');
colormap summer
h=legend('TODO','Finished');
set(h,'position',[0.05 0.05 0.2 0.2]);