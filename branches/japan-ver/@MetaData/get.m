function varargout=get(md,varargin)
% GET properties of MetaData object
% Only works on a single object not array, if you want to get for an array,
% use a loop...

%% check to see if md is an array, if so run foreach element seperatly.
% this chunk is a big ugly, could flip the loop and avoid the second loop,
% but who cares...
if length(md)>1
    varargout={};
    s=cell(length(md),length(varargin));
    for i=1:length(md)
        for j=1:length(varargin)
            s{i,j}=get(md(i),varargin{j});
        end
    end
    for j=1:length(varargin)
        varargout=[varargout {s(:,j)}];
    end
    return
end

%% From here down is the call for a single MetaData object

varargout=cell(size(varargin));
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'metadata'
            varargout{i}=md;
        case 'collections'
            varargout{i}=md.CollectionData.Collection;
        case 'relations'
            varargout{i}=md.CollectionData.Relation;
        case 'imagetype'
            varargout{i}=md.Image.ImageType;
        case 'filename'
            varargout{i}=md.Image.ImageFileName;
        case 'creationdate'
            varargout{i}=md.Image.CreationDate;
        case 'description'
            varargout{i}=md.Image.Description;
        case 'pixeltype'
            varargout{i}=md.Image.PixelType;
        case 'bitdepth'
            varargout{i}=str2double(md.Image.BitDepth);
        case 'pixelsizex'
            varargout{i}=str2double(md.Image.PixelSizeX);
        case 'pixelsizey'
            varargout{i}=str2double(md.Image.PixelSizeY);
        case 'pixelsizez'
            varargout{i}=str2double(md.Image.PixelSizeZ);
        case 'channels'
            varargout{i}=md.Image.ChannelInfo;
        case 'dimensionorder'
            varargout{i}=md.Image.DimensionOrder;
        case 'dimensionsize'
            varargout{i}=str2arr(md.Image.DimensionSize);
        case 'qdata'
            for j=1:length(md.Image.Qdata)
                md.Image.Qdata(j).Value=str2arr(md.Image.Qdata(j).Value);
            end
            varargout{i}=md.Image.Qdata;
        case 'planenum'
            varargout{i}=md.Image.PlaneData.PlaneNum;
        case 'binning'
            varargout{i}=str2arr(md.Image.PlaneData.Binning);
        case 'stagex'
            varargout{i}=str2arr(md.Image.PlaneData.StageX);
        case 'stagey'
            varargout{i}=str2arr(md.Image.PlaneData.StageY);
        case 'stagez'
            varargout{i}=str2arr(md.Image.PlaneData.StageZ);
        case 'planetime'
            varargout{i}=str2arr(md.Image.PlaneData.PlaneTime);
        case 'exposuretime'
            varargout{i}=str2arr(md.Image.PlaneData.ExposureTime);
        case 'displaymode'
            varargout{i}=md.DisplayOptions.DisplayMode;
        case 'displaylevels'
            varargout{i}=str2arr(md.DisplayOptions.Levels);
        case 'displaychannels'
            varargout{i}=str2arr(md.DisplayOptions.Channels);
        case 'displayroi'
            varargout{i}=str2arr(md.DisplayOptions.ROI);
        case 'xml'
            varargout{i}=['<III>' struct2xml(struct(md)) '</III>'];
        case 'channelnames'
            channelnames={md.Image.ChannelInfo(:).ChannelName};
            varargout{i}=channelnames;
        otherwise
            error('attribute %s is not part of MetaData properties interface',varargin{i});
    end
end

            
            
            
            
            