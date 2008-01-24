function plotPlannedSchedule(rS)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

TskNonExec=getTasks(rS,'status','inqueue');
[x,y,id]=get(TskNonExec,'stagex','stagey','id');
if iscell(x)
   x=[x{:}]'; y=[y{:}]'; id=[id{:}]';
end

% the purpose of thie ismember is to sort them according to the right
% order
[bla,ind]=ismember(rS.TaskSchedule,id);
ind=ind(ind>0);
plot(x(ind),y(ind),'-')
axis([min(x(ind))-10 max(x(ind))+10 min(y(ind))-10 max(y(ind))+10]);
