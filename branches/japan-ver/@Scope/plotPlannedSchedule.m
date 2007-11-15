function plotPlannedSchedule(rS,fig)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fig','var')
    fig=figure;
end

figure(fig);
clf
hold on
TskNonExec=getTasks(rS,'nonexecuted');
[x,y,id]=get(TskNonExec,'stagex','stagey','id');
if iscell(x)
   x=[x{:}]'; y=[y{:}]'; id=[id{:}]';
end
[bla,ind]=ismember(rS.TaskSchedule,id);
ind=ind(ind>0);
plot(x(ind),y(ind),'-')
axis([min(x(ind))-10 max(x(ind))+10 min(y(ind))-10 max(y(ind))+10]);