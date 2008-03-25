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

for i=1:length(plotInfo)
    if plotInfo(i).num == 0
        fig=figure; 
    else
        fig=plotInfo(i).num;
    end
    figure(fig)
    set(fig,'position',plotInfo(i).position,...
                        'Toolbar','none','Menubar','none',...
                        'name',plotInfo(i).type);
    clf
    switch lower(plotInfo(i).type)
        case 'focal plane'
            plotFocalPlaneGrid(rS);
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
if ~isempty(get(rS,'printscreen'))
    chld=get(0,'children');
    for i=1:length(chld)
        filename=fullfile(get(rS,'printscreen'),['frame_' num2str(chld(i)) '.tiff']);
        imwrite(frame2im(getframe(chld(i))),filename,'WriteMode','append');
    end
    
end
    
            