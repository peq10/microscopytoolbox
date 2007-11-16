%%
MiscData.ProjectName='InitialTest';
MiscData.DatasetName='Tst1';
MiscData.Experimenter='Roy Wollman';
MiscData.Experiment='testing throopi the roboscope';
MiscData.ImageName='Img'; 

%% Create the grid
Pos=createAcqPattern('grid',[0 0],10,10,1000,zeros(100,1));
T=linspace(0,19*3,100);

% Details of all channels.
ExposureDetails(1).channel='White';
ExposureDetails(1).exposure=10;


%% Create a series of dependent tasks
Tsks = createTaskSeries(MiscData,Pos,T,ExposureDetails,'acq_goto');
set(rS,'x',0,'y',0,'z',0)
removeTasks(rS,'all')
addTasks(rS,Tsks);

%% Plot the grid 
figure(1)
clf
hold on
plotPlannedSchedule(rS,1)

%% visit all grid points
run(rS);

%% get the real XYs
Tsks2=getTasks(rS,'all'); %get all tasks from buffer
exe=get(Tsks2,'executed');
exe=[exe{:}]';
MDs=get(Tsks2,'MetaData');
MDs=[MDs{:}]';
[x,y]=get(MDs,'stage.x','stage.y');
x=[x{:}]';
y=[y{:}]';
%% plot real grid
plot(x,y,'ro')

%% histogram of error
figure(2)
clf
hold on
dx=(x-[Pos(:).X]');
dy=(y-[Pos(:).Y]');
hist([dx dy ],15)
legend('dX','dY')
xlabel('positioning error in micron')
text(0.4,20,['mean:' num2str(mean([dy; dx])) ' std:' num2str(std([dy; dx]))])

