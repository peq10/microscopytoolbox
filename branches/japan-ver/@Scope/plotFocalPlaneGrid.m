function plotFocalPlaneGrid( rS )
%PLOTFOCALPLANEGRID plots the current known focal plane

XYZ=get(rS,'focalplane');
if isempty(XYZ), XYZ=zeros(3,3,3); end
surf(XYZ(:,:,1),XYZ(:,:,2),XYZ(:,:,3));
