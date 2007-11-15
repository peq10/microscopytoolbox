function  run( rSin )
%RUN all tasks in TaskSchedule

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
    updateStatusBar(rS,0)
    if ~isempty(Tsk)
        if get(rS,'resolveErrors')
            try
                t0=now;
                Tsk=do(Tsk);
                dur=now-t0;
                replaceTasks(rS,set(Tsk,'executed',true,'duration',dur));
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
                    replaceTasks(rS,set(Tsk,'executed',true));
                catch
                    warning('Failed AGAIN - this isn''t my day');
                end
            end
        else
            t0=now;
            Tsk=do(Tsk);
            dur=now-t0;
            replaceTasks(rS,set(Tsk,'executed',true,'duration',dur));
        end
    end
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end

function resolveError(err)
% this subfunction 
global rS;

%% try to recover from MM errors by unloading and loading all
% devices, than give it another shot.
if~isempty(findstr(err,'mmcorej'))
    unload(rS);
    loadDevices(rS);
end

%% try to recover from memory error by unloading packing and reloading mmc
if ~isempty(findstr(err,'memory'))
    unload(rS);
    rS.mmc=[];
    pack;
    rS.mmc=CMMCore;
    rS.mmc.loadSystemConfiguration('MM_Roboscope.cfg');
end