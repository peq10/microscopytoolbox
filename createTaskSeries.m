function Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,acqFcn)
% createTaskSeries: create an array of serially dependent tasks. 
%                   it gathers all acquisition details and creates Tasks objects. 
% 
% Usage:
% MiscData           - struct with misc data: Names of project, dataset, etc.  
% Pos                - array of structs with the fields: X,Y,Z. 
% T                  - array of time to image each object (t0=0);
% ExposureDetails    - struct with exposure details (2 fields: channel,exposure)
% acqFns             - the acq function (will be the same for all Tasks)

%% 

global rS;
% set channels
chnls=squeeze(struct2cell(ExposureDetails));
exptime=sum([chnls{2,:}])/1000; % sum all channels and change units to seconds
chnls=chnls(1,:);


for i=1:length(Pos)
    
    %% create the MetaData object
    % 1. constructor call
    MD=MetaData('Template.ome');
    % 2. set specific fields
    % set all the 'global' attributes, all the non image related
    MD = set(MD,...
        'Project.Name',MiscData.ProjectName,...
        'Dataset.Name',MiscData.DatasetName,...
        'Objective',get(rS,'objective'),...
        'Experimenter',MiscData.Experimenter,...
        'Experiment',MiscData.Experiment,...
        'PixelSizeX',get(rS,'PixelSize'),...
        'PixelSizeY',get(rS,'PixelSize'),...
        'Stage.X',Pos(i).X,...
        'Stage.Y',Pos(i).Y,...
        'Stage.Z',Pos(i).Z,...
        'channels',chnls,...
        'exposuredetails',ExposureDetails,...
        'image.name',[MiscData.ImageName '_' num2str(i)]);
       
    %% create the Task, dependencies exist from i>1
    if i==1
        Tsks(i) = Task(MD,acqFcn);
    else
        dt=T(i)-T(i-1);
        Tsks(i) = Task(MD,acqFcn,[get(Tsks(i-1),'id') dt]);
    end
    Tsks(i)=set(Tsks(i),'acqTime',exptime,'focusTime',get(rS,'focusTime'));
end
   


