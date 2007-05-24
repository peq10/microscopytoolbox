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
        [bla,ind]=intersect(Sch(:,1),id);
        rS.TaskSchedule=sortrows(Sch(ind,:),2); 
    case 'ants_tsp'
        % create a .tsp file

        % run ACT
