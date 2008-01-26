function plotTaskStatusByType(rS)

Tsks=getTasks(rS,'all');
[fncStr,status]=get(Tsks,'fcnstr','status');

unqStt=unique(status);

[unqFnc,bla,m]=unique(fncStr);
tbl=tabulate(m);

stts=zeros(length(unqStt),length(unqFnc));

for i=1:size(tbl,1)
    for j=1:length(unqStt)
        stts(j,i)=sum(strcmp(status,unqStt{j}).*strcmp(fncStr,unqFnc{i}));
    end
end
stts=[zeros(1,length(unqStt)); stts'];

barh(stts,'stacked')
set(gca,'yticklabel',unqFnc,'ylim',[1.5 size(tbl,1)+1.5]);
xlabel('Number of Tasks');
colormap summer
h=legend(unqStt);
set(h,'position',[0.05 0.05 0.2 0.2]);