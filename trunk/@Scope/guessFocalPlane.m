function z = guessFocalPlane( rS, x,y )
%GUESSFOCALPLANE zi = guessFocalPlane( rS, x,y )
% gives a guess as to the currnet focal plane based on the focal planbe grid

XYZ=get(rS,'focalplane');

try
    z=interp2(XYZ(:,:,1),XYZ(:,:,2) ,XYZ(:,:,3),x,y );   
catch
    z=NaN;
end

if isnan(z) 
    %meaning that either interp2 failed or its out of range
    % trying to use nearest neighbour instead
    if ~isempty(rS.FocusPoints)
        curr_xy=rS.FocusPoints(:,1:2)';
        D=distance(curr_xy,[x; y]);
        [bla,mi]=min(D);
        z=rS.FocusPoints(mi,3);
    else %even nearest neighbour failed...
        warning('Cannot guess position with current set of points!') %#ok<WNTAG>
    end
end

