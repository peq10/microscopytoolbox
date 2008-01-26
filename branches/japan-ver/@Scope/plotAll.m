function plotAll(rS)

plotInfo=get(rS,'plotInfo');

for i=1:length(plotTypes)
    figure(plotInfo(i).num,'position',plotInfo(i).position,...
                        'Toolbar','none','Menubar','none',...
                        'name',plotInfo(i).type);
    clf
    switch lower(plotInfo(i).type)
        case 'focal plane'
            plotFocalPlaneGrid(rS);
        case 'past route'
            plotPastRoute(rS);
        case 'planned schedule'
            plotPlannedSchedule(rS);
        case 'route'
            plotRoute(rS);
        case 'route 3d'
            plotRoute3D(rS);
        case 'task status'
            plotTaskStatus(rS);
        case 'task status by type'
            plotTaskStatusByType(rS);
        case 'image'
            plotImage(rS);
    end
end

drawnow;
            