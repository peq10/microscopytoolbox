function varargout = get(rS,varargin)
%GET properties of the Score object rS
%   for details on what the properties are see developer guide. 

varargout={};
% get: 
% X,Y,Z,Fcs,Channel,ExpTime
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'x'
            [ok,xpos]=cmdStg(rS,'where','X');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {xpos}];
        case 'y'
            [ok,ypos]=cmdStg(rS,'where','Y');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {ypos}];
        case 'z'
            [ok,zpos]=cmdStg(rS,'where','Z');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {zpos}];
        case 'channel'
             varargout=[varargout; {rS.mmc.getCurrentConfig('Channel')}];
        case 'exposure'
            varargout=[varargout; {rS.mmc.getExposure}];
        case 'width'
            varargout=[varargout; {rS.mmc.getImageWidth}];
        case 'height'
            varargout=[varargout; {rS.mmc.getImageHeight}];
        case 'bitdepth'
            varargout=[varargout; {rS.mmc.getImageBitDepth}];
        case 'rootfolder'
            varargout=[varargout; {rS.rootFolder}];
        case 'pixelsize'
        case 'objective'
            varargout=[varargout; {rS.mmc.getStateLabel('Objective')}];
        case 'focusmethod'
            varargout=[varargout; {rS.focusMethod}];
        case 'stagebusy'
            [ok,bsy]=cmdStg(rS,'getStatus');
            varargout=[varargout; bsy];
        case {'focusscore',...
              'focusrange',...
              'focusspeed',...
              'focussearchdirection',...
              'focususehilldetect',...
              'focushilldetectheight'}
          varargout=[varargout; {getFocusParams(rS,varargin{i})}];
        otherwise
            warning(['property: ' varargin{i} ' does not exist in Scope class']) %#ok
    end
end

