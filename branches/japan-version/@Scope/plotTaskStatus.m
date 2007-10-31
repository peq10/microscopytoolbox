function plotTaskStatus(rS)

Timed=getTasks(rS,'timed');
NonTimed=getTasks(rS,'nontimed');
if isempty(Timed)
    texec=0;
else
    exec=get(Timed,'executed');
    if iscell(exec)
        exec=[exec{:}];
    end
    texec=sum(exec);
end
stts(:,1)=[length(Timed)-texec texec]';
exec=get(NonTimed,'executed');
if isempty(NonTimed)
    texec=0;
else
    if iscell(exec)
        exec=[exec{:}];
    end
    texec=sum(exec);
end
stts(:,2)=[length(NonTimed)-texec texec]';

barh(stts','stacked')
set(gca,'yticklabel',{'Timed','Non-Timed'},'ylim',[0.5 2.5]);
xlabel('Number of Tasks');
colormap summer
h=legend('TODO','Finished');
set(h,'position',[0.05 0.05 0.2 0.2]);