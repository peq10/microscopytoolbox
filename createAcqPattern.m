function Pos = createAcqPattern( pattern,varargin )
%CREATEACQPATTERN create a Pos struct with X,Y,Z fields
%
% Usage: 
%    Pos - a struct with the three needed arrays (X,Y,Z)
%    pattern - one of: 'singleSpot','grid','circle','UserDef'
%
%    varargin will contain a pattern dependent set of varialbe: 
%
%   timelapse:  Pos = createAcqPattern('timelapse',center,N)
%   grid:          Pos = createAcqPattern('grid',center,r,c,dist,z)
%   circle:        Pos = createAcqPattern('circle',center,N)
%   userdef:     Pos = createAcqPattern('userdef',X,Y,Z)

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
         if length(varargin)~=5, 
             error('''grid'' option requires 5 input arguments');
         end
         center=varargin{1}; 
         r=varargin{2}; 
         c=varargin{3}; 
         dist=varargin{4}; 
         z=num2cell(varargin{5}); 
         xy=fullfact([r c]);
         x=num2cell((xy(:,1)-r/2)*dist+center(1)); 
         y=num2cell((xy(:,2)-c/2)*dist+center(2)); 
         Pos=struct('X',x,'Y',y,'Z',z);
    case 'circle'
        %TODO write the 'circle' option for the createAcqPattern function
    case 'userdef'
        Pos=struct('X',num2cell(varargin{1}),...
                   'Y',num2cell(varargin{1}),...
                   'Z',num2cell(varargin{1}));
    otherwise
        Pos=struct('X',{},'Y',{},'Z',{});
        warning('Unknown pattern, please try again') %#ok
end