function plotPlannedSchedule(rS,fig)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fig','var')
    fig=figure;
end

figure(fig);
clf
hold on
[x,y,id]=get(rS.TaskBuffer,'stagex','stagey','id');
x=[x{:}]'; y=[y{:}]'; id=[id{:}]';
[bla,ind]=ismember(rS.TaskSchedule,id);
plot(x(ind),y(ind),'.-')
axis([min(x(ind))-10 max(x(ind))+10 min(y(ind))-10 max(y(ind))+10]);