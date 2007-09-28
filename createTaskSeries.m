function Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,Binning,acqFcn,UserData)
% createTaskSeries: create an array of serially dependent tasks. 
%                   it gathers all acquisition details and creates Tasks objects. 
% 
% Usage:
% Collections        - struct with Coll data, fields: CollType CollName
%                      if Collections is array must be the size of Pos               
% Pos                - array of structs with the fields: X,Y,Z. 
% T                  - array of time to image each object (t0=0), any task that is non time
%                      dependent should have T==NaN
% ExposureDetails    - struct with exposure details (2 fields: channel,exposure)
%                      ExposureDetails(i).exposure could be array but then must be the same size of Pos 
% Binning            - value of binng to use, if array must be same size of Pos
% acqFns             - the acq function (will be the same for all Tasks)

%% 

global rS;
N=length(Pos);

% set channels
chnls=squeeze({ExposureDetails(:).channel});
% find out exposure, if scalar turn to 2D matrix (Exp x Channel x Pos)
for i=1:length(ExposureDetails)
    if length(ExposureDetails(i).exposure)==1
        ExposureDetails(i).exposure=repmat(ExposureDetails(i).exposure,length(
exptime=sum([chnls{2,:}])/1000; % sum all channels and change units to seconds
chnls=chnls(1,:);

if ~exist('UserData','var')
    UserData=[];
end

%% create the first task 
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
    'Stage.X',Pos(1).X,...
    'Stage.Y',Pos(1).Y,...
    'Stage.Z',Pos(1).Z,...
    'channels',chnls,...
    'exposuredetails',ExposureDetails,...
    'image.name',[MiscData.ImageName '_' num2str(1)]);
Tsks(1) = Task(MD,acqFcn);
Tsks(1) = set(Tsks(1),'UserData',UserData);

%% create rest of tasks by changing MD and adding dependencies
for i=2:length(Pos);
    MD=set(MD,'Stage.X',Pos(i).X,...
        'Stage.Y',Pos(i).Y,...
        'Stage.Z',Pos(i).Z,...
        'image.name',[MiscData.ImageName '_' num2str(i)]);
    dt=T(i)-T(i-1);
    Tsks(i) = Task(MD,acqFcn,[get(Tsks(i-1),'id') dt]);
    Tsks(i)=set(Tsks(i),'acqTime',exptime,'focusTime',get(rS,'focusTime'));
    
    Tsks(i) = set(Tsks(i),'UserData',UserData);
end
   


