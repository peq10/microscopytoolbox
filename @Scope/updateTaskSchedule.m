function updateTaskSchedule( rSin, mthd,varargin)
%UPDATETASKSCHEDULE update the current TaskBuffer schedule 
%
% default method is 'ants_tsp'


% this trick make sure rS is updated 
% notice that rSin MUST be the same global rS object. 
global rS;
rS=rSin;

%% get info about tasks in buffer

% get the IDs,x,y of all non-executed tasks. 
x=[];
y=[]; 
id=[];
for i=1:length(rS.TaskBuffer)
    exec=get(rS.TaskBuffer(i),'executed'); 
    if ~exec
        x=[x; get(rS.TaskBuffer(i),'stageX')]; 
        y=[y; get(rS.TaskBuffer(i),'stageY')];
        id=[id; get(rS.TaskBuffer(i),'ID')];
    end
end

%% set default method
if ~exist('mthd','var')
    mthd=get(rS,'schedulingMethod'); 
end

%% apply scheduling method
switch lower(mthd)
    case 'manual'
        Sch=varargin{1}; 
        %get only methods that exist in TaskBuffer
        [bla,ind]=intersect(Sch(:,1),id); %#ok
        rS.TaskSchedule=sortrows(Sch(ind,:),2); 
    case 'ants_tsp'
        rS.TaskSchedule=[];
        % first check to see if qualifies (>20 pnts, range >0) 
        if range(x)+range(y)==0
            tr=1:length(id);
        else
            % create a .tsp file
            fid=fopen('Tasks.tsp','w');
            fprintf(fid,'NAME : Tasks\n');
            fprintf(fid,'COMMENT : Imaging positions\n');
            fprintf(fid,'TYPE : TSP\n');
            fprintf(fid,'DIMENSION : %g\n',length(id));
            fprintf(fid,'EDGE_WEIGHT_TYPE : EUC_2D\n');
            fprintf(fid,'NODE_COORD_SECTION\n');
            for i=1:length(x), fprintf(fid,'%g %g %g\n',i,x(i),y(i)); end
            fprintf(fid,'EOF\n');
            fclose(fid);

            % run ACOTSP
            cmd=sprintf('acotsp -i Tasks.tsp -r 1 -t 3 -g %i',min(length(id),20));
%             cmd=sprintf('acotsp -i Tasks.tsp -r 1 -t 3');
            msg=system(cmd); %#ok<NASGU>
            if msg==0
                tr = dlmread('Tour.txt');
                tr=tr(1:length(x));
                tr=tr+1;
            else
                warning('Scheduling failed!!!!! no idea why... ')
                keyboard
                tr=1:length(x);
            end

        end
        
        % rotate points on the circle such that the closest Task is first
        [x_current,y_current]=get(rS,'x','y');
        [bla,cls_id]=min(sqrt((x(tr)-x_current).^2+(y(tr)-y_current).^2)); %#ok
        tr_srt=tr([cls_id:length(id) 1:cls_id-1]);
        id_srt=id(tr_srt);
        
        % inter task distance - used for time calculation below.
        dx=sqrt((x(2:length(id_srt))-x(1:length(id_srt)-1)).^2+(y(2:length(id_srt))-y(1:length(id_srt)-1)));
        
        % build the schedule object - assigns times for tasks
        rS.TaskSchedule(1,:)=id_srt;
%         for i=2:length(id)
%             stageTime=dx(i-1)./get(rS,'stageSpeed.x');
%             % get the indexes for the previous and current tasks. 
%             [bla,indx]=getTasks(rS,id_srt(i),2); %#ok
%             [bla,prev_indx]=getTasks(rS,id_srt(i-1),2); %#ok
%             
%             %update the expected time for Task to start. 
% %             tm(i)=tm(i-1)+get(rS.TaskBuffer(indx),'runTime')+stageTime;
% %             
% %             % update the minimal delay time after previous task. 
% %             dep=get(rS.TaskBuffer(indx),'dependencies');
% %             if isempty(dep), dep=zeros(1,2); end
%             rS.TaskSchedule(i,:)=[id_srt(i) tm(i) dep(1,2)];
%         end
        
end
