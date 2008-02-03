function plotRoute(rS)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

allsym='^<>vdh*h+o.sph';

cla
tb=getTasks(rS,'status','executed');
[X,Y,T,typ]=get(tb,'stagex','stagey','planetime','fcnstr');
if ~iscell(X)
    if ~isempty(X)
        hold on
        plot(X,Y,'o')
    end
    return
end
xyt=sortrows([[X{:}]' [Y{:}]' ([T{:}]'-min([T{:}]))*1440],3);

unqFnc=unique(typ);

% now round the xy to 10 micron
xyt(:,1:2)=10*round(xyt(:,1:2)/10);

xyunq=unique(xyt(:,1:2),'rows');

for i=1:size(xyunq,1)
    ind=find((xyt(:,1)==xyunq(i,1)).*(xyt(:,2)==xyunq(i,2)));
    xyt(ind,4)=length(ind)+10;
    xyt(ind,5)=max(xyt(ind,3));
end

plotPlannedSchedule(rS,fig)
hold on

for i=1:length(unqFnc)
    ind=strcmp(typ,unqFnc{i});
    sym=allsym(mod(i,length(allsym))+1);
    scatter(xyt(ind,1),xyt(ind,2),xyt(ind,4),xyt(ind,5),sym,'filled');
end

% legend([{'plan'}; unqFnc(:)],'location','southoutside')
axis equal
% colorbar

