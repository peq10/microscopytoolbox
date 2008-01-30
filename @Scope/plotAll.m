function plotAll(rS)
% plotAll updates all figures as configured in plotInfo attribute
%    there are several types of plots that rS know how to generate. Which
%    one is ploted, its figure number and position is determined using the
%    plotInfo attribute (use set/get). 
% 
% plotAll is basically the aggregator of all the private plotting function.
% It is possible to also set manually the configuration and save it using
% set(rS,'plotInfo','current'). 
% 
% example: 
%         plotAll(rS)

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
            