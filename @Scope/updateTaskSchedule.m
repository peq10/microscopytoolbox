function  updateTaskSchedule( rS, mthd,varargin)
%UPDATETASKSCHEDULE update the current TaskBuffer schedule 
%
% default method is 
%% get info about tasks in buffer

% get the IDs,x,y of all non-executed tasks. 
x=[];
y=[]; 
id=[];
for i=1:length(rS.TaskBuffer)
    exec=get(rS.TaskBuffer(i),'executed'); 
    if ~exec
        x=[x; get(rS.TaskBuffer,'X')]; 
        y=[y; get(rS.TaskBuffer,'Y')];
        id=[id; get(rS.TaskBuffer,'ID')];
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
        % create a .tsp file
        
        fid=fopen('Tasks.tsp','w');
        fprintf(fid,'NAME: Tasks\n');
        fprintf(fid,'COMMENT: Imaging positions\n');
        fprintf(fid,'TYPE: TSP\n');
        fprintf(fid,'DIMENSION: %g\n',length(id));
        fprintf(fid,'EDGE_WEIGHT_TYPE : EUC_2D\n');
        fprintf(fid,'NODE_COORD_SECTION\n');
        for i=1:length(id), fprintf(fid,'%g %g %g\n',i,x(i),y(i)); end
        fprintf(fid,'EOF\n');
        fclose(fid)
        
        % run ACT
        !ThirdParty/scheduling/acotsp -i Tasks.tsp -r 1 -t 1
        tr = dlmread('Tour.txt');
        tr=tr(1:100);
        tr=tr+1;

        % rotate such that the closest Task is first
%         [x_current,y_current]=get(rS,'x','y'); 
        [bla,cls_id]=min(sqrt((x(tr)-x_current).^2+(y(tr)-y_current).^2)); %#ok
        tr_srt=tr([cls_id:100 1:cls_id-1]);
        
        id_srt=id(tr_srt);
        dx=sqrt((x(2:length(id_srt))-x(1:length(id_srt)-1)).^2+(y(2:length(id_srt))-y(1:length(id_srt)-1)));
        
        % build the schedule object - assigns times for tasks
        tm(1)=0;
        rS.TaskSchedule(1,:)=[id_srt(1) tm];
        for i=2:length(id)
            stageTime=dx(i-1)./get(rS,'stageSpeed');
            % get the indexes for the previous and current tasks. 
            [bla,indx]=getTasks(rS,id_srt(i)); %#ok
            [bla,prev_indx]=getTasks(rS,id_srt(i)); %#ok
            
            %update the expected time for Task to start. 
            tm(i)=tm(i-1)+get(rS.TaskBuffer(indx),'runTime')+stageTime;
            
            % update the minimal delay time after previous task. 
            dep=get(rS.TaskBuffer(indx),'dependencies');
            if isempy(dep), dep=zeros(1,2); end
            rS.TaskSchedule(i,1)=[id_srt(i) tm(i) dep(1,2)];
        end
        
end
