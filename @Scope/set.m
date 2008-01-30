function set(rSin, varargin)
% set : changes the attributes of the Scope object rS
%   for details on what the properties are see doc 
%   it can change multiple attributes in the same call
%
% example: 
%          [fldr,xpos,pfson]=get(rS,'rootFolder','x','pfs')

global rS;
rS=rSin;

n=length(varargin); 

if mod(n,2)~=0, error('must have PAIRS of feature name, feature value'); end

for i=1:2:n
    switch lower(varargin{i})
        case 'plotinfo' % inputs: the char 'current' that would grab the figure status as they are or a struct with fields: 'type','num','positoin' fields. 
            % array from current open figures. 
            if ischar(varargin{i+1}) && strcmp(varargin{i+1},'current')
                chld=get(0,'children');
                for ii=1:length(chld)
                    cnf(i)=struct('type',get(chld(ii),'name'),...
                                   'num',ii,...
                                   'position',get(chld(ii),'position'));
                end
                varargin{i+1}=cnf;
            end
            % check its a struct with the right field names
            if ~isstruct(varargin{i+1})
                error('plotInfo must be a struct')
            end
            if ~isequal(sort(fieldnames(varargin{i+1})),{'num','position','type',})
                error('plotInfo must have the fields: num / position /type');
            end
            rS.plotInfo=varargin{i+1};
        case 'resolveerrors' %  logical (would be converted to logical anyway)
            rS.resolveErrors=logical(varargin{i+1});
        case 'refreshschedule' %  scalar integer (would be rounded to one if necessary)
            if ~isreal(varargin{i+1}) && numel~=1 && round(varargin{i+1})<1
                error('''refreshschedule'' must be positive integer scalar');
            end
            rS.refreshSchedule=round(varargin{i+1});
        case 'obj' %  a legal objective state label as defined in MM config file
            if ~strcmp(varargin{i+1},get(rS,'obj'))
               rS.mmc.setStateLabel(rS.OBJName,varargin{i+1});
            end
                
        case 'pfs' %  logical (will be converted) also will only act if input is different than get(rS,'pfs')
            if logical(get(rS,'pfs'))~=logical(varargin{i+1})
                try
                    rS.mmc.enableContinuousFocus(varargin{i+1});
                catch
                    warning('Failed to chagne PFS'); %#ok<WNTAG>
                end
            end
        case 'roi' % a four element array of number: [x,y,xsize,ysize]  
            if ~isreal(varargin{i+1}) && numel~=4
                error('''ROI'' must be a four element real vector: [x,y,xsize,ysize]');
            end
            rS.mmc.setROI(varargin{i+1}(1),varargin{i+1}(2),varargin{i+1}(3),varargin{i+1}(4));
        case 'focalplanegridsize' % a single integer > 0 (will be rounded)
            if ~isreal(varargin{i+1}) && numel~=1 && round(varargin{i+1})<1
                error('''focalplanegridsize'' must be positive scalar integer');
            end
            rS.FocalPlaneGridSize=round(varargin{i+1});
        case 'focuspointsproximity' % single number in um units
            if ~isreal(varargin{i+1}) && numel~=1 && round(varargin{i+1})<=0
                error('''focuspointsproximity'' must be positive scalar');
            end
            rS.FocusPointHistory=varargin{i+1};
        case 'focuspointshistory' % single number in um units
            if ~isreal(varargin{i+1}) && numel~=1 && round(varargin{i+1})<=0
                error('''focuspointshistory'' must be positive scalar');
            end
            rS.FocusPointHistory=varargin{i+1};
        case 'x' % single number in um units (absolute cordinates)
            x=varargin{i+1};
            y=rS.mmc.getYPosition(rS.XYstageName);
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
        case 'y' % single number in um units (absolute cordinates)
            x=rS.mmc.getXPosition(rS.XYstageName);
            y=varargin{i+1};
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
        case 'xy' % a vector of [x,y] position in um
            x=varargin{i+1}(1);
            y=varargin{i+1}(2);
            rS.mmc.setXYPosition(rS.XYstageName,x,y);
%   %% Following section is a "HACK" done to artificially slow the speed, better 
%   %% to fix the speed property and use that. 
%       c ase 'xy-slow'
%             x=varargin{i+1}(1);
%             y=varargin{i+1}(2);
%             [curr_x,curr_y]=get(rS,'x','y');
%             xint=linspace(curr_x,x,6);
%             yint=linspace(curr_y,y,6);
%             xint=xint(2:end);
%             yint=yint(2:end);
%             for j=1:5
%                 set(rS,'xy',[xint(j) yint(j)])
%                 pause(0.2);
%             end
            
        case'z' % single number in um units (absolute cordinates)
            rS.mmc.setPosition(rS.ZstageName,varargin{i+1})
        case 'stagespeed.x' % TODO: implement stagtespeed.X via mmc
        case 'stagespeed.y' % TODO: implement stagtespeed.y via mmc
        case 'stagespeed.z' % TODO: implement stagtespeed.z via mmc
            
% %% This section was             
%             [bla,ax]=strtok(varargin{i},'.');
%             param.axis=upper(ax(2));
%             param.speed=varargin{i+1}/1000; 
%             ok=cmdStg(rS,'setspeed',param);
%             if ~ok
%                 warning('Could not set stage speed appropriatly.') %#ok
%             end

        case 'channel' % a string of a channel group name (as defined in MM config file) get them using get(rS,'avaliablechannels')
             % check that config is char
            if ~ischar(varargin{i+1}), error('Channel state must be char!'); end
            % Capitalize channel first letter
            varargin{i+1}(1)=upper(varargin{i+1}(1));
            % check that config state is "legal"
            if ~(rS.mmc.isConfigDefined(rS.ChannelName,varargin{i+1}))
                error([varargin{i+1} ' is not a legitimate Channel configuration, check config file']);
            end
            % Only if Channel need changing, change it...
            if ~strcmp(varargin{i+1},get(rS,'Channel'))
                rS.mmc.setConfig(rS.ChannelName,varargin{i+1});
            end
        case 'exposure' % real positive scalar units: msec
            % check input - real and numel==1
            if ~isreal(varargin{i+1}) || numel(varargin{i+1})~=1 || varargin{i+1} <0
                error('Exposure must be a double positive scalar!');
            end
            rS.mmc.setExposure(varargin{i+1});
        case 'rootfolder' % a legal path to somewhere in the file system. 
            if ~ischar(varargin{i+1}) || ~exist(varargin{i+1},'dir')
                error('rootFolder must be a string and a legit folder, please check');
            end
            rS.rootFolder=varargin{i+1};
        case 'focusrange' 
        case 'focusspeed'
        case 'focussearchdirection'
        case 'focususehilldetect'
        case 'focushilldetectheight'
             setFocusParams(rS,varargin{i},varargin{i+1});
        case 'lastimage' % an image
            rS.lastImage=varargin{i+1};
        case 'schedulingmethod' % a string speficiying a legal scheduling method e.g. it exist in the SchdualerFcns folder
            if ~ismember(varargin{i+1},get(rS,'avaliableschdeulingmethods'))
                error('Not a legal scheduling method');
            end
            rS.schedulingMethod=varargin{i+1};
        case 'focusmethod' % a legal focus methods TODO: not check of legality is implemented. 
            rS.focusMethod=varargin{i+1};
        case 'binning' % a positive scalar integer
            if ~isreal(varargin{i+1}) && numel~=1 && round(varargin{i+1})<1
                error('''binning'' must be positive integer scalar');
            end
            rS.mmc.setProperty('DigitalCamera','Binning',num2str(round(varargin{i+1})));
        case 'autoshutter' % logical (would be convered if necessary)
            rS.mmc.setAutoShutter(logical(varargin{i+1}))
        otherwise
            warning('Unrecognized attribute') %#ok
    end
end