function plotPlannedSchedule(rS,fig)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('fig','var')
    fig=figure;
end

figure(fig);
clf
hold on
[x,y,id]=get(rS.TaskBuffer,'x','y','id');
x=[x{:}]'; y=[y{:}]'; id=[id{:}]';
[bla,ind]=ismember(rS.TaskSchedule(:,1),id);
plot(x(ind),y(ind),'.-')