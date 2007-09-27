function set(rSin, varargin)
%SET sets rS internal properties. 
% call set(rs) for list of arguments

global rS;
rS=rSin;

n=length(varargin);
allowed_properties={...
    'x','y','z','xy','xz','yz','xyz','channel','exposure','whiteshutter','flourshutter','rootFolder'}; %#ok<NASGU>

% If 'set' is called without input argument beside rS, 
% return list of legal properties
if n==0, 
    for i=1:length(allowed_properties)
        disp(allowed_properties{i});
    end
    return
end

if mod(n,2)~=0, error('must have PAIRS of feature name, feature value'); end

for i=1:2:n
    switch lower(varargin{i})
        case 'x'
            x=varargin{i+1};
            y=rS.mmc.getYPosition(rS.XYstageName);
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
        case 'y'
            x=rS.mmc.getXPosition(rS.XYstageName);
            y=varargin{i+1};
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
        case 'xy'
            x=varargin{i+1}(1);
            y=varargin{i+1}(2);
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
        case'z'
            rS.mmc.setPosition(rS.ZstageName,varargin{i+1})
        case {'stagespeed.x','stagespeed.y','stagespeed.z'}
            [bla,ax]=strtok(varargin{i},'.');
            param.axis=upper(ax(2));
            param.speed=varargin{i+1}/1000; 
            ok=cmdStg(rS,'setspeed',param);
            if ~ok
                warning('Could not set stage speed appropriatly.') %#ok
            end
        case 'channel'
             % check that config is char
            if ~ischar(varargin{i+1}), error('Channel state must be char!'); end
            % Capitalize channel first letter
            varargin{i+1}=regexprep(varargin{i+1}, '(^.)', '${upper($1)}');
            % check that config state is "legal"
            if ~(rS.mmc.isConfigDefined('Channel',varargin{i+1}))
                error([varargin{i+1} ' is not a legitimate Channel configuration, check config file']);
            end
            % Only if Channel need changing, change it...
            if ~strcmp(varargin{i+1},get(rS,'Channel'))
                rS.mmc.setConfig('Channel',varargin{i+1});
            end
        case 'exposure'
            % check input - real and numel==1
            if ~isreal(varargin{i+1}) || numel(varargin{i+1})~=1,
                error('Exposure must be a double scalar!');
            end
            rS.mmc.setExposure(varargin{i+1});
        case 'rootFolder'
            if ~ischar(varargin{i+1}) || ~exist(varargin{i+1},'dir')
                error('rootFolder must be a string and a legit folder, please check');
            end
            rS.rootFolder=varargin{i+1};
        case {'focusrange',...
              'focusspeed',...
              'focussearchdirection',...
              'focususehilldetect',...
              'focushilldetectheight'}
             setFocusParams(rS,varargin{i},varargin{i+1});
        case 'lastimage'
            rS.lastImage=varargin{i+1};
        case 'schedulingmethod'
            rS.schedulingMethod=varargin{i+1};
        case 'focusmethod'
            rS.focusMethod=varargin{i+1};
        case 'binning'
            rS.mmc.setProperty('DigitalCamera','Binning',num2str(varargin{i+1}));
        case 'autoshutter'
            rS.mmc.setAutoShutter(logical(varargin{i+1}))
        otherwise
            warning('Unrecognized attribute') %#ok
    end
end