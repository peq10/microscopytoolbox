function Pos = createAcqPattern( pattern,varargin )
%CREATEACQPATTERN create a Pos struct with X,Y,Z fields
%
% Usage: 
%    Pos - a struct with the three needed arrays (X,Y,Z)
%    pattern - one of: 'singleSpot','grid','circle','UserDef'
%
%    varargin will contain a pattern dependent set of varialbe: 
%
%   timelapse:  Pos = createAcqPattern('singleSpot',center,N)
%   grid:          Pos = createAcqPattern('grid',center,N)
%   circle:        Pos = createAcqPattern('circle',center,N)
%   userdef:     Pos = createAcqPattern('userdef',N)

switch lower(pattern)
    case 'timelapse'
        center=varargin{1}; 
        N=varargin{2};
        for i=1:N
            Pos(i).X=center(:,1);
            Pos(i).Y=center(:,2);
            Pos(i).Z=center(:,3);
        end
     case 'grid'
        %TODO write the 'grid' option for the createAcqPattern funcrion
    case 'circle'
        %TODO write the 'circle' option for the createAcqPattern function
    case 'userdef'
end