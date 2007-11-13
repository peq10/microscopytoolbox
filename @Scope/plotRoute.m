function plotRoute(rS,fig)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fig','var')
    fig=figure;
end

figure(fig)
hold on

tb=getTasks(rS,'executed');
[X,Y,T]=get(tb,'stagex','stagey','planetime');
if ~iscell(X)
    if ~isempty(X)
        hold on
        plot(X,Y,'o')
    end
    return
end
xyt=sortrows([[X{:}]' [Y{:}]' ([T{:}]'-mean([T{:}]))*24*3600],3);

% now round the xy to 10 micron
xyt(:,1:2)=10*round(xyt(:,1:2)/10);

xyunq=unique(xyt(:,1:2),'rows');

for i=1:size(xyunq,1)
    ind=find((xyt(:,1)==xyunq(i,1)).*(xyt(:,2)==xyunq(i,2)));
    xyt(ind,4)=length(ind)+3;
    xyt(ind,5)=max(xyt(ind,3));
end

hold on
scatter(xyt(:,1),xyt(:,2),xyt(:,4),xyt(:,5),'filled');



