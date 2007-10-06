function updateStatusBar( rSin,percentWaitToNextTask )
%UPDATESTATUSBAR for overall progress and currne task
% percentWaitToNextTask is for the lower bar - upper bar is calculated on the fly
% to clear statusbar, call with percentWaitToNextTask=[]; 

if isempty(percentWaitToNextTask)
    delete(statusbar2);
    return
end

global rS;
rS=rSin;

% if rS doesn't hold a status bar handle create one
if isempty(rS.statusBarHandle) || ~ishandle(rS.statusBarHandle)
    delete(statusbar2);
    rS.statusBarHandle=statusbar2('Throopi''s progress');
end

h=rS.statusBarHandle;

exec=get(rS.TaskBuffer,'executed'); 
exec=double([exec{:}]);

h=statusbar2(sum(exec)/length(exec),percentWaitToNextTask,h);
statusbar2(h,'Time to next task');

