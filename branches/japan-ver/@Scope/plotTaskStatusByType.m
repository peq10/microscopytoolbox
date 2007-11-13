function plotTaskStatusByType(rS)

Tsks=getTasks(rS,'all');
[fncStr,exec]=get(Tsks,'fcnstr','executed');
exec=[exec{:}];

[unq,bla,m]=unique(fncStr);
tbl=tabulate(m);

stts=zeros(size(tbl,1),2);

for i=1:size(tbl,1)
    stts(i,2)=sum(exec(m==i));
    stts(i,1)=sum(m==i)-stts(i,2);
end
    
barh(stts,'stacked')
set(gca,'yticklabel',unq,'ylim',[0.5 size(tbl,1)+0.5]);
xlabel('Number of Tasks');
colormap summer
h=legend('TODO','Finished');
set(h,'position',[0.05 0.05 0.2 0.2]);