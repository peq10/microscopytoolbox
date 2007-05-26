%% Create the grid
Pos=createAcqPattern('grid',[0 0],10,10,1000,zeros(100,1));

%% Plot the grid 
figure(1)
clf
hold on
plot([Pos(:).X],[Pos(:).Y],'.-');

%% visit all grid points
set(rS,'x',0,'y',0,'z',0)
for i=1:100
    tic
    fprintf('Not attempting %g %g\n',Pos(i).X,Pos(i).Y);
    set(rS,'x',Pos(i).X,'y',Pos(i).Y,'z',Pos(i).Z)
    while get(rS,'stageBusy')
        disp('pausing')
        pause(0.01)
    end
    [x(i),y(i),z(i)]=get(rS,'x','y','z');
    tm(i)=toc;
end

%% plot real grid
scatter(x,y,tm*10,[1 0 0])

%% histogram of error
figure(2)
clf
hold on
dx=(x-[Pos(:).X])';
dy=(y-[Pos(:).Y])';
hist([dx dy ],15)
legend('dX','dY')
xlabel('positioning error in micron')
text(0.4,20,['mean:' num2str(mean([dy; dx])) ' std:' num2str(std([dy; dx]))])

