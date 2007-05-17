function varargout = get(rS,varargin)
%GET Summary of this function goes here
%   Detailed explanation goes here

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
        case 'fcsscr' %uses direct serial communication
            [ok,fcsscr]=cmdStg(rS,'fcsscr');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {fcsscr}];
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
        case 'pixelsizestruct'
        case 'stagebusy'
            [ok,bsy]=cmdStg(rS,'getStatus');
            varargout=[varargout; bsy];
        case 'finefocusrange'
            [ok,param]=cmdStg('getFocusParam');
            
        case 'focusspeed'
            
        otherwise
            warning(['property: ' varargin{i} ' does not exist in Scope class']) %#ok
    end
end

