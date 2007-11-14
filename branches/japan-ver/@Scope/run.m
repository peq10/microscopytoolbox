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
        try
            t0=now;
            Tsk=do(Tsk);
            dur=now-t0;
            replaceTasks(rS,set(Tsk,'executed',true,'duration',dur));
        catch
            % ersolve the error
%             UserData=get(Tsk,'UserData');
            err=lasterr;
%             UserData.ExecutionFailure=err;
%             Tsk=set(Tsk,'UserData',UserData);
%             replaceTasks(rS,Tsk);
            warning(['TASK HAS FAILED WITH ERROR   ' err]);
            if ishandle(herr), delete(herr); end
            herr=msgbox(err);
            %% try to revcover from MM errors by unloading and loading all
            %% devices, than give it another shot. 
            if~isempty(findstr(err,'mmcorej'))
                unload(rS);
                loadDevices(rS);
                try
                    Tsk=do(Tsk);
                    replaceTasks(rS,set(Tsk,'executed',true));
                catch
                    warning('Failed AGAIN - this isn''t my day');
                end
            end
        end
    end
    rS.TaskSchedule=rS.TaskSchedule(2:end);
end
