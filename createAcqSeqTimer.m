function t = AcqSeq(MiscData,AcqPos,ExposureDetails,acqFns,Name,Tag)
% AcqSeq constractor, gathers all acquisition details for the Dataset that
% will be acquired. It sets up a array of MetaData objects, one for each planned
% image. Each MetaData object will contain all the necessary details for
% acquisition, e.g. X,Y,Z,T, Image Name etc. 
% 
% Usage:
% MiscData           - struct with misc data: Names, Objective, 
% Pos                   - struct with the arrays: X,Y,Z,T. 
% ExposureDetails - struct with exposure details (2 fields: channel,exposure)
% acqFns              - struct with names of all 4 functions (empty means default)

% % These are all the initializing data structures, they are used to create
% % the MetaData array which is how AcqSeq object wil store the data. In the debug
% % version I'm keeping those structs, in later version this might go away...
% AqSq.MiscData=MiscData;
% AqSq.Pos=Pos;
% AqSq.ExposureDetails=ExposureDetails;
% AqSq.acqFns=acqFns;

% Tag is useful to tag several timers as the same group, for reporting
% purposes. 
if ~exist('Tag','var')
    Tag='';
end


%% Generate the MetaData array

% Create MDs from template. Array length is the 
% length of AcqPos which is the number of sites in the sequence
% For each image there is a MetaData object
MDs=MetaData(length(AcqPos.X)); % generate the default MetaData object

% first set all the 'global' attributes, all the non image related
MDs=set(MDs,...
                'Project.Name',MiscData.ProjectName,...
                'Dataset.Name',MiscData.DatasetName,...
                'Objective',MiscData.Objective,...
                'Experimenter',MiscData.Experimenter,...
                'Experiment',MiscData.Experiment);

 % set pixel size - same is all images
global rS;
PixelSizeStruct=get(rS,'PixelSizeStruct');               % rS is holding the table of pixels sizes
if ~isfield(PixelSizeStruct,MiscData.Objective); 
    error(['Objective ' MiscData.Objective ' is not valid, please check']); 
end
pxsz=PixelSizeStruct.(MiscData.Objective); % get the right one from the struct
MDs=set(MDs,'PixelSizeX',pxsz(1),'PixelSizeY',pxsz(2));            

 % set positions for each image
 MDs=set(MDs,'Stage.X',Pos.X,'Stage.Y',Pos.Y,'Stage.Z',Pos.Z,'dt',Pos.dt);
                
% set channels
chnls=squeeze(struct2cell(ExposureDetails));
chnls=chnls(1,:);
MDs= set(MDs,'channels',chnls);
 
% set images names  (different between images)    
%TODO


%% Set up other timer properties

% set the acquisition functions
% change empty to defaults
if isempty(acqFns.acq), acqFns.acq='AcqFcn/simpleAcq'; end
if isempty(acqFns.start), acqFns.start='disp(''starging acquisition...'')'; end
if isempty(acqFns.stop), acqFns.stop='disp(''stopping acquisition...'')'; end
if isempty(acqFns.error), acqFns.error='disp(''Error during acquisition'')'; end


%% create the timer
UserData.MDs=MDs;
UserData.lastImage=[];

t=timer(...
    'BusyMode','queue',...
    'ExecutionMode','fixedDelay',...
    'Period',Pos.dt,...
    'TasksToExecute',legnth(MDs),...
    'UserData',UserData,...
    'TimerFcn',acqFns.acq,...
    'StartFcn',acqFns.start,...
    'StopFcn',acqFns.stop,...
    'ErrorFcn',acqFns.error,...
    'tag',Tag,...
    'Name',Name
    );

%% make the class
AqSq=class(AqSq,'AcqSeq',t);


