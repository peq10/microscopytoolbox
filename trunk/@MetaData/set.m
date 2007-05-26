function md=set(md,varargin)
% SET values/attributes to node 'node' 
% md = set(md,node,value) - to change value of leaf node
% md = set(md,node,keys,vals) - to change attributes of element node
%                                keys,vals are same length cell arrays
%
% 

possibleFields={'project.name','dataset.name','image.name','objective','experimenter','experiment',...
                       'pixelsizex','pixelsizey','pixelsizez','stage.x','stage.y','stage.z','channels','creationdate',...
                       'display.r','display.g','display.b','display.r_levels','display.g_levels','display.b_levels',...
                       'display.gray','display.gray_levels','dimension_order','sizex','sizey','sizez','sizet','sizec',...
                        'firstt', 'firstc', 'firstz','dt'};

                   
%% input validation
n=length(varargin);
m=length(md);

% If 'set' is called without input argument beside rS, 
% return list of legal properties
if n==0, 
    for i=1:length(possibleFields)
        disp(possibleFields{i});
    end
    return
end

if mod(n,2)~=0, error('must have PAIRS of feature name, feature value'); end

%% if md is an array, call set foreach element 

if m>1
    % recreate varargin
    for i=1:2:n
        if length(varargin{i})==1
            v=repmat(varargin{i+1},m,1);
        else
            v=varargin{i+1};
        end
        for j=1:m
            md(i)=set(md(i),varargin{i},v);
        end
    end
     return
end
    

%% actually setting the values...

xml=md.xml;

for i=1:2:n
    switch lower(varargin{i})
        case 'project.name'
            % name must be char
            if ~ischar(varargin{i+1}), error('Project name must be char'); end
            xml=sub_set(xml,'/OME/Project','Name',varargin{i+1});
        case 'dataset.name'
            % name must be char
            if ~ischar(varargin{i+1}), error('Dataset name must be char'); end
            md.xml=sub_set(xml,'/OME/Dataset','Name',varargin{i+1});
        case 'image.name'
            % name must be char
            if ~ischar(varargin{i+1}), error('Image name must be char'); end
            xml=sub_set(xml,'/OME/Image','Name',varargin{i+1});
        case 'objective'
            % objective must exist in the xml already - using sub_keep
            [xml,fnd]=sub_keep(xml,'/OME/Instrument/Objective','SerialNumber',varargin{i+1});
            if ~fnd, warning('Objective does not exist - please check'); end %#ok
        case 'experimenter'
            % only one experimenter allowed, must be char and must exist in
            % template. 
            firstname=strtok(varargin{i+1});
            [xml,fnd]=sub_keep(xml,'/OME/Experimenter/FirstName','value',firstname);
            if ~fnd, warning('Experimenter does not exist - please check'); end %#ok
        case 'experiment'
            xml=sub_set(xml,'/OME/Experiment/Description',varargin{i+1});
        case {'pixelsizex','pixelsizey','pixelsizez'}
            % pixel size must be numeric
            if ~isa(varargin{i+1},'numeric'), warning('Pixel size must be numeric'); end %#ok
            px=varargin{i};
            px([1 6 10])=upper(px([1 6 10])); 
            xml=sub_set(xml,'/OME/Image',px,num2str(varargin{i+1}));
        case {'stage.x','stage.y','stage.z'}
            % stage position must be numeric
            if ~isa(varargin{i+1},'numeric'), warning('Stage position must be numeric'); end %#ok
            [bla,ax]=strtok(varargin{i},'.'); %#ok 
            ax=ax(2:end);
            ax=upper(ax);
            xml=sub_set(xml,'/OME/Image/StageLabel',ax,num2str(varargin{i+1}));
        case 'channels'
            % Channels must exist in the xml already - using sub_keep
            [xml,fnd]=sub_keep(xml,'/OME/Image/ChannelInfo','Name',varargin{i+1});
            % TODO need to renumber the channels
            if ~fnd, warning('Channels do not exist - please check'); end %#ok
        case 'exposuredetails'
            md.ExposureDetailes=varargin{i+1};
        case 'creationdate'
            % converts to correct format using matlab's datenum, make sure
            % datenum gets you the right date...
             xml=sub_set(xml,'/OME/Image/CreationDate',datestr(datenum(varargin{i+1}),30));
        case {'display.r','display.g','display.b','display.gray'}
            % get the chanel number for the channel you are interested in
            chnls=sub_get(xml,'/OME/Image/ChannelInfo','Name');
            chnms=sub_get(xml,'/OME/Image/ChannelInfo/ChannelComponent','Index');
            % check to see that channel is legit
            chnm=chnms(ismember(chnls,varargin{i+1}));
            if isempty(chnm), warning('could not find the right channel for the display potion'), end %#ok
            [bla,ch]=strtok(varargin{i},'.'); %#ok
            if strcmp(ch,'gray') 
                dispch='Gray'; 
            else
                chDisp={'Red','Green','Blue'};
                dispch=chDisp{ismember('rgb',ch)};
            end
            xml=subset(xml,['/OME/Image/DisplayOptions/' dispch 'Channel'],'ChannelNumber',chnm);
        case {'display.r_levels','display.g_levels','display.b_levels','display.gray_levels'}
            % get the channel name
            [bla,ch]=strtok(strtok(varargin{i},'_'),'.'); %#ok
            if strcmp(ch,'gray') 
                dispch='Gray'; 
            else
                chDisp={'Red','Green','Blue'};
                dispch=chDisp{ismember('rgb',ch)};
            end
            xml=sub_set(xml,['/OME/Image/DisplayOptions/' dispch 'Channel/'],'BlackLevel',num2str(varargin{i+1}(1))); 
            xml=sub_set(xml,['/OME/Image/DisplayOptions/' dispch 'Channel/'],'WhiteLevel',num2str(varargin{i+1}(2))); 
        case 'dimension_order'
            xml=sub_set(xml,'/OME/Image/Pixels','DimensionOrder',varargin{i+1});
        case 'sizex'
            xml=sub_set(xml,'/OME/Image/Pixels','SizeX',num2str(varargin{i+1}));
        case 'sizey'
            xml=sub_set(xml,'/OME/Image/Pixels','SizeY',num2str(varargin{i+1}));
        case 'sizez'
            xml=sub_set(xml,'/OME/Image/Pixels','SizeZ',num2str(varargin{i+1}));
        case  'sizet'
            xml=sub_set(xml,'/OME/Image/Pixels','SizeT',num2str(varargin{i+1}));
        case 'sizec'
            xml=sub_set(xml,'/OME/Image/Pixels','SizeC',num2str(varargin{i+1}));
        case 'firstt'
            xml=sub_set(xml,'/OME/Image/Pixels/TiffData','FirstT',num2str(varargin{i+1}));
        case 'firstz'
            xml=sub_set(xml,'/OME/Image/Pixels/TiffData','FirstZ',num2str(varargin{i+1}));
        case 'firstc'
            xml=sub_set(xml,'/OME/Image/Pixels/TiffData','FirstC',num2str(varargin{i+1}));
        case 'dt'
            xml=sub_set(xml,'/OME/Image','TimeIncrement',num2str(varargin{i+1}));
    end
end

% update the md object
md.xml=xml;

