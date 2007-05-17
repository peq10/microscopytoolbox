function varargout = get(rS,varargin)
%GET Summary of this function goes here
%   Detailed explanation goes here

varargout={};
% get: 
% X,Y,Z,Fcs,Channel,ExpTime
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'x'
            [ok,cnf]=cmdStg(rS,'where','X');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {str2double(cnf(4:end))}];
        case 'y'
            [ok,cnf]=cmdStg(rS,'where''Y');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {str2double(cnf(4:end))}];
        case 'z'
            [ok,cnf]=cmdStg(rS,'where','Z');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {str2double(cnf(4:end))}];
        case 'fcsscr' %uses direct serial communication
            [ok,cnf]=cmdStg(rS,'fcsscr');
            if ~ok, warning('Stage cmd failed'); end %#ok
            varargout=[varargout; {str2double(cnf(4:end))}];
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
        otherwise
            warning(['property: ' varargin{i} ' does not exist in Scope class']) %#ok
    end
end

