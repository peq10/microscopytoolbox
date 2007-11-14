function set(rSin, varargin)
%SET sets rS internal properties. 
% call set(rs) for list of arguments

global rS;
rS=rSin;

n=length(varargin); 

if mod(n,2)~=0, error('must have PAIRS of feature name, feature value'); end

for i=1:2:n
    switch lower(varargin{i})
        case 'refreshschedule'
            rS.refreshSchedule=varargin{i+1};
        case 'obj'
            if ~strcmp(varargin{i+1},get(rS,'obj'))
               rS.mmc.setStateLabel('OBJ',varargin{i+1});
            end
                
        case 'pfs'
            if logical(get(rS,'pfs'))~=logical(varargin{i+1})
                try
                    rS.mmc.enableContinuousFocus(varargin{i+1});
                catch
                    warning('Failed to chagne PFS'); %#ok<WNTAG>
                end
            end
        case 'roi'
            rS.mmc.setROI(varargin{i+1});
        case 'focalplanegridsize'
            rS.FocalPlaneGridSize=varargin{i+1};
        case 'focuspointsproximity'
            rS.FocusPointHistory=varargin{i+1};
        case 'focuspointhistory'
            rS.FocusPointHistory=varargin{i+1};
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
        case 'xy-slow'
            x=varargin{i+1}(1);
            y=varargin{i+1}(2);
            [curr_x,curr_y]=get(rS,'x','y');
            xint=linspace(curr_x,x,6);
            yint=linspace(curr_y,y,6);
            xint=xint(2:end);
            yint=yint(2:end);
            for j=1:5
                set(rS,'xy',[xint(j) yint(j)])
                pause(0.2);
            end
            
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
            varargin{i+1}(1)=upper(varargin{i+1}(1));
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
        case 'rootfolder'
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
        case 'statusbarposition'
            if ~isempty(rS.statusBarHandle)
                set(rS.statusBarHandle,'position',varargin{i+1});
            end
        otherwise
            warning('Unrecognized attribute') %#ok
    end
end