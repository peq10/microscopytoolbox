function plotFocalPlaneGrid( rS ,fig)
%PLOTFOCALPLANEGRID plots the current known focal plane

if exist('fig','var')
    figure(fig);
end

XYZ=get(rS,'focalplane');
if isempty(XYZ), XYZ=zeros(3,3,3); end
surf(XYZ(:,:,1),XYZ(:,:,2),XYZ(:,:,3));
