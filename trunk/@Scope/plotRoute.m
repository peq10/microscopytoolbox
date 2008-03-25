function plotRoute(rS)
% plotRoute  : plots the route that rS took so far. 
%   The pased route that rS has gone through is plotted. This is based on
%   all the tasks that are saved in the buffer but are of status 'executed'
% 
%   Different tasks types get a different symbol. The marker size is
%   proportional to the number of time been in specific site. 

% symbols for different task types
allsym='^<>vdh*h+o.sph';

cla
%% get all information about Past executed tasks. 
tb=getTasks(rS,'status','executed');
[X,Y,T,typ]=get(tb,'stagex','stagey','acqtime','fcnstr');
if ~iscell(X)
    if ~isempty(X)
        hold on
        plot(X,Y,'o')
    end
    return
end
[xyt,ind]=sortrows([[X{:}]' [Y{:}]' ([T{:}]'-min([T{:}]))*1440*60],3);
typ=typ(ind);

%% transform the data into single row per xy-position
% with additional info about the number of time in that position and the 
unqFnc=unique(typ);

% now round the xy to 10 micron
xyt(:,1:2)=10*round(xyt(:,1:2)/10);

xyunq=unique(xyt(:,1:2),'rows');

for i=1:size(xyunq,1)
    ind=find((xyt(:,1)==xyunq(i,1)).*(xyt(:,2)==xyunq(i,2)));
    % size of marker - how many time have you been in this spot
    xyt(ind,4)=length(ind)+100;
    % color of marker - how long ago was it
    xyt(ind,5)=max(xyt(ind,3));
end

%% 
plot(xyt(:,1),xyt(:,2))
hold on

for i=1:length(unqFnc)
    ind=strcmp(typ,unqFnc{i});
    sym=allsym(mod(i,length(allsym))+1);
    scatter(xyt(ind,1),xyt(ind,2),xyt(ind,4),xyt(ind,5),sym,'filled');
end

legend([{'plan'}; unqFnc(:)],'location','EastOutside')
axis([min(xyt(:,1))-10 max(xyt(:,1))+10 min(xyt(:,2))-10 max(xyt(:,2))+10]);
axis equal
colorbar

