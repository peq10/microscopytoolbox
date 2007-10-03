function plotFocalPlaneGrid( rS )
%PLOTFOCALPLANEGRID plots the current known focal plane

XYZ=get(rS,'focalplane');
surf(XYZ(:,:,1),XYZ(:,:,2),XYZ(:,:,3));
