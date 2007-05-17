function Pos = createAcqPattern( pattern,varargin )
%CREATEACQPATTERN create a Pos struct with X,Y,Z fields
%
% Usage: 
%    Pos - a struct with the three needed arrays (X,Y,Z)
%    pattern - one of: 'singleSpot','grid','circle','UserDef'
%
%    varargin will contain a pattern dependent set of varialbe: 
%
%   timelapse:  Pos = createAcqPattern('singleSpot',center,N,dt)
%   grid:          Pos = createAcqPattern('grid',center,N,pixsize)
%   circle:        Pos = createAcqPattern('circle',center,N,pixsize)
%   userdef:     Pos = createAcqPattern('userdef',N)

switch lower(pattern)
    case 'timelapse'
        center=varargin{1}; 
        N=varargin{2};
        Pos.X=ones(N,1).*center(:,1);
        Pos.Y=ones(N,1).*center(:,2);
        Pos.Z=ones(N,1).*center(:,3);
        Pos.dt=varargin{3};
        Pos.pattern=lower(pattern);
    case 'grid'
        %TODO write the 'grid' option for the createAcqPattern funcrion
    case 'circle'
        %TODO write the 'circle' option for the createAcqPattern function
    case 'userdef'
end