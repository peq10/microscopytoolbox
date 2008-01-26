function plotTaskStatus(rS)

Timed=getTasks(rS,'timedependent',true);
NonTimed=getTasks(rS,'timedependent',false);
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
if isempty(NonTimed)
    texec=0;
else
    exec=get(NonTimed,'executed');
    if iscell(exec)
        exec=[exec{:}];
    end
    texec=sum(exec);
end
stts(:,2)=[length(NonTimed)-texec texec]';

barh(stts','stacked')
set(gca,'yticklabel',{['Timed   ' num2str(stts(2,1)) '/' num2str(stts(1,1))] ,...
                      ['Non-Timed   ' num2str(stts(2,2)) '/' num2str(stts(1,2))]},'ylim',[0.5 2.5]);
xlabel('Number of Tasks');
colormap summer
h=legend('TODO','Finished');
set(h,'position',[0.05 0.05 0.2 0.2]);