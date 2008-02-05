function plotPlannedSchedule(rS)
% plotPlannedSchedule :  plots the route that rS will take. 
%   for all the tasks in the queue, gets their position and plots a line
%   that goes through the positions according to the order they will be
%   visited by the rS. 

TskNonExec=getTasks(rS,'status','inqueue');
[x,y,id]=get(TskNonExec,'stagex','stagey','id');
if iscell(x)
   x=[x{:}]'; y=[y{:}]'; id=[id{:}]';
end

%% Here we sort & plot. 
% the purpose of the ismember is to sort them according to the right
% order. rS.TaskSchedule has the order where as id is currently in the same
% order as x,y variables. the use of ismember (Its a trick:) will return
% the variable "ind" with the right order, e.g. the order you need to have
% id in to get TaskSchedule (since id(ind)=rS.TaskSchedule). 
[bla,ind]=ismember(rS.TaskSchedule,id);
ind=ind(ind>0);
plot(x(ind),y(ind),'.-')
axis([min(x(ind))-10 max(x(ind))+10 min(y(ind))-10 max(y(ind))+10]);
