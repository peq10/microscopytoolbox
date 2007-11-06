function md = set(md, varargin )
%SET properties of MetaData
%   can set a only a single object at a time. 

if ~numel(varargin) || mod(length(varargin),2)
    error('set must get at least one PAIR of proerpty name / values')
end

if length(md)>1
    error('Can only set MetaData objects one by one, please use a loop');
end

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'collections'
            if sum(ismember(fieldnames(varargin{i+1}),{'CollType';'CollName'}))~=2
                error('Wrong fields for collection structs')
            end
            varargin{i+1}=orderfields(varargin{i+1},{'CollType';'CollName'});
            md.CollectionData.Collection=varargin{i+1};
        case 'relations'
            if sum(strcmp(fieldnames(varargin{i+1}),{'sub';'dom'}))~=2
                error('Wrong fields for collection structs')
            end
            md.CollectionData.Relation=varargin{i+1};
        case 'imagetype'
            if ~ischar(varargin{i+1})
                error('Image type must be a char');
            end
            md.Image.ImageType=varargin{i+1};
        case 'filename'
            if ~ischar(varargin{i+1})
                error('Image filename must be a char');
            end
            md.Image.ImageFileName=varargin{i+1};
        case 'creationdate'
            if ~ischar(varargin{i+1})
                error('Image CreationDate must be a char');
            end
            md.Image.CreationDate=varargin{i+1};
        case 'description'
            if ~ischar(varargin{i+1})
                error('Image Description must be a char');
            end
            md.Image.Description=varargin{i+1};
        case 'pixeltype'
            if ~ischar(varargin{i+1})
                error('Image PixelType must be a char');
            end
            md.Image.PixelType=varargin{i+1};
        case 'bitdepth'
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=1
                error('Image BitDepth must be signle numeric');
            end
            md.Image.BitDepth=num2str(varargin{i+1});
        case 'pixelsizex'
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=1
                error('Image PixelSize must be signle numeric');
            end
            md.Image.PixelSizeX=num2str(varargin{i+1});
        case 'pixelsizey'
            if ~isa(varargin{i+1},'numeric')|| numel(varargin{i+1})~=1
                error('Image PixelSize must be signle numeric');
            end
            md.Image.PixelSizeY=num2str(varargin{i+1});
        case 'pixelsizez'
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=1
                error('Image PixelSize must be signle numeric');
            end
            md.Image.PixelSizeZ=num2str(varargin{i+1});
        case 'channels'
            if sum(ismember(fieldnames(varargin{i+1}),{'Number'; 'ChannelName'; 'Content'}))~=3
                error('Wrong fields for Channel struct')
            end
            varargin{i+1}=orderfields(varargin{i+1},{'Number'; 'ChannelName'; 'Content'});
            md.Image.ChannelInfo=varargin{i+1};
        case 'dimensionorder'
            if ~ischar(varargin{i+1})
                error('Image DimensionOrder must be a char');
            end
            md.Image.DimensionOrder=varargin{i+1};
        case 'dimensionsize'
            if ~isnumeric(varargin{i+1}) || numel(varargin{i+1}) > 3
                error('Image DimensionSize must be numeric with numel <=3');
            end
            md.Image.DimensionSize=arr2str(varargin{i+1});
        case 'imgheight'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('ImgHeight must be numeris and <= 3D')
            end
            md.Image.PlaneData.ImgHeight=arr2str(varargin{i+1});
        case 'imgwidth'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('ImgWidth must be numeris and <= 3D')
            end
            md.Image.PlaneData.ImgWidth=arr2str(varargin{i+1});
        case 'stagex'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('StageX must be numeris and <= 3D')
            end
            md.Image.PlaneData.StageX=arr2str(varargin{i+1});
        case 'stagey'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('StageY must be numeris and <= 3D')
            end
            md.Image.PlaneData.StageY=arr2str(varargin{i+1});
        case 'stagez'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('StageZ must be numeris and <= 3D')
            end
            md.Image.PlaneData.StageZ=arr2str(varargin{i+1});
        case 'planetime'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('PlaneTime must be numeric and <= 3D')
            end
            md.Image.PlaneData.PlaneTime=arr2str(varargin{i+1});
        case 'exposuretime'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('ExposureTime must be numeris and <= 3D')
            end
            md.Image.PlaneData.ExposureTime=arr2str(varargin{i+1});
        case 'binning'
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('Binning must be numeris and <= 3D')
            end
            md.Image.PlaneData.Binning=arr2str(varargin{i+1});
        case 'qdata'
            if ~isstruct(varargin{i+1}), 
                error('Qdata must be a struct');
            end
            if ~isequal(fieldnames(varargin{i+1}),{'QdataType';'Value';'QdataDescription'})
                % test it only a matter of order
                varargin{i+1}=orderfields(varargin{i+1},{'QdataType'; 'Value'; 'QdataDescription'});
                % if still not equal, throw an error
                if ~isequal(fieldnames(varargin{i+1}),{'QdataType';'Value';'QdataDescription'})
                    error('Wrong fields for Qdata struct')
                end
            end
            for j=1:length(varargin{i+1})
                varargin{i+1}(j).Value=arr2str(varargin{i+1}(j).Value);
            end
            md.Image.Qdata=varargin{i+1};
        case 'displaymode'
            if ~ischar(varargin{i+1}) || ~sum(ismember(varargin{i+1},{'Gray','RGB','Comp'}))
                error('Unsupported disaply mode - must be Gray / RGB / Comp');
            end
            md.Image.DisplayOptions.DisplayMode=varargin{i+1};
        case 'displaylevels'
            if ~isa(varargin{i+1},'numeric') || size(varargin{i+1},1)~=4 || size(varargin{i+1},2)~=2
                error('Display levels must be numeric 4 x 2 matrix')
            end
            md.Image.DisplayOptions.Levels=arr2str(varargin{i+1});
        case 'displaychannels'
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=4 
                error(['Display channel must be numeric 4 element vector which references the:\n'...
                         'channel for the Red Green Blue and Gray disaply channels, set 0 for none']);
            end
            %check that all the channels are legal 
            chnlstrct=get(md,'Channels'); 
            for j=1:length(varargin{i+1})
                if varargin{i+1}(j)>0 && ((varargin{i+1}(j) > length(chnlstrct)) || (isempty(chnlstrct(varargin{i+1}(j)).Content))) 
                    error('Content index for display channels indexes an illegal channel\n either channel doesni''t exist or its empty')
                end
            end
            md.Image.DisplayOptions.Channels=arr2str(varargin{i+1});
        case 'displayroi'
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=4 
                error('Display levels must be numeric 4 element matrix')
            end
            md.Image.DisplayOptions.ROI=arr2str(varargin{i+1});
        otherwise
            error('attribute %s is not part of MetaData properties interface',varargin{i});
    end
end
 