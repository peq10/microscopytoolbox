function addFocusPoints( rSin,x,y,z,t )
% addFocusPoints : add points to the rS.FocusPoints and mark old ones not to be used
% the Scope object is constantly maintaining a list of points that it think
% were in good focus. This method adds a point to this list. When a point
% is added other older points might be marked as old based on Scope attributes
% FocusPointProximity and FocuPointHistory. The list of focal points is
% then used to build a model of the coverslip (the get(rS,'focalplane'))
% 
% To obatin the added focal points call get(rS,'focuspoints')
% To obtain ALL the focas points (including discarded) call
% get(rS,'allfocuspoints')
%
% rSin - global rS object
% x,y,z - the coordinates of last focus
% t - time this focus point was acquired (in seconds since 1/1/0)
%
% example: 
% 
%         addFocusPoints( rS,get(rS,'x'),get(rS,'y'),get(rS,'z'),now)


global rS;
rS=rSin;

% if FocusPoint is empty, just add point
if isempty(rS.FocusPoints)
    rS.FocusPoints=[x y z t ones(size(x))];
    return
end

% Find the indexes of point I want to marks as old of points 
% (e.g. are closer then rS.FocusPointProximity and 
%  were taken more than rS.FocuPointHistory seconds ago)
curr_xy=rS.FocusPoints(:,1:2)';
D=distance(curr_xy,[x'; y']);
T=(t-rS.FocusPoints(:,4));
ix=find((D<get(rS,'FocusPointsProximity')).*(T>get(rS,'FocusPointsHistory'))); 
rS.FocusPoints(ix,5)=0; %#ok<FNDSB>

% add current point
rS.FocusPoints=[rS.FocusPoints; x y z t ones(size(x))];
