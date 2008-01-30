function  run( rSin )
% run : performs all tasks in TaskSchedule acording their order. 
%    The main functionality here is just to go over all tasks 
%    using getTasks(rS,'next'). 
%    Beside that it also manages rS behaviour that is related to schedule
%    refresh (when the schedule is reclaculted every N tasks. 
%    Also if get(rS,'resolveErrors') is true it tries to resolve the error
%    using its private function resoveErrors. Currently only mmc and memory
%    related error are recoverable. 
% 
% example: 
%           run(rS)

global rS;
rS=rSin;

herr=[];
cnt=0;
while ~isempty(rS.TaskSchedule)
    cnt=cnt+1;
    if cnt==get(rS,'refreshschedule');
        fprintf('refreshing schedule\n')
        updateTaskSchedule(rS);
        cnt=0;
    end
    Tsk=getTasks(rS,'next');
    if ~isempty(Tsk)
        if get(rS,'resolveErrors')
            try
                Tsk=do(Tsk);
                replaceTasks(rS,set(Tsk,'status','executed'));
            catch
                % try to resolve the error
                err=lasterr;
                disp(['TASK HAS FAILED WITH ERROR   ' err]);
                if ishandle(herr), delete(herr); end
                herr=msgbox(err);

                %% calling sub-function to try and resolve the error
                resolveError(err)

                %% try to redo the last task
                try
                    Tsk=do(Tsk);
                    replaceTasks(rS,set(Tsk,'status','executed'));
                catch
                    warning('Failed AGAIN - this isn''t my day'); %#ok
                end
            end
        else
            Tsk=do(Tsk);
            replaceTasks(rS,set(Tsk,'status','executed'));
        end
    end
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end

function resolveError(err)
% this subfunction tries to resolve the error based on what it was. 
% if it is MMC related it unloads and load devices. 
% if it is memory - closes all figures and only keep rS

global rS;

%% try to recover from MM errors by unloading and loading all devices
% devices, than give it another shot.
if ~isempty(findstr(err,'mmcorej'))
    unload(rS,'config.dump');
    loadDevices(rS,'config.dump');
end

%% try to recover from memory error by unloading packing and reloading mmc
if ~isempty(findstr(err,'memory'))
    close all
    keep rS
end