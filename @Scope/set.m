function set(rS, varargin)
%SET sets rS internal properties. 
% call set(rs) for list of arguments

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
        case {'x','y','z','xy','xz','yz','xyz'}
            if ~isreal(varargin{i+1}) && numel(varargin{i+1})~=numel(varargin{i})
                error(['Send ' varargin{i} ' as REAL number such that number of axis equal to positions']);
            end
            % create the parameter struct
            for j=1:length(varargin{i})
                param(j).axis=varargin{i}(j);
                param(j).position=varargin{i+1}(j);
            end
            ok=cmdStg(rS,'move',param);
            if ~ok
                warning('Could not move to sepecified position') %#ok
            end
        case 'channel'
            % check that config is char
            if ~ischar(varargin{i+1}), error('Channel state must be char!'); end
            % Capitalize channel
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
        case 'whiteshutter'
        case 'flourshutter'
        case 'rootFolder'
            if ~ischar(varargin{i+1}) || ~exist(varargin{i+1},'dir')
                error('rootFolder must be a string and a legit folder, please check');
            end
            rS.rootFolder=varargout
        otherwise
            warning('Unrecognized attribute')
    end
end