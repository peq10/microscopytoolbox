function varargout=get(md,varargin)
% get : attributes of MetaData object (ar array of objects). 
%    md must be of class MetaData but could be an array. Varargin is a list
%    of attributes that would be returned. If md is an array, each return
%    variable will be a cell array. 
%
% example: 
%          [xml,wd]=get(md,'xml','imgwidth');


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
        case 'imgwidth' % number of columns in the image matrix. 
            varargout{i}=str2arr(md.ImgWidth);
        case 'imgheight' % number of rows in the image matrix.
            varargout{i}=str2arr(md.ImgHeight);
        case 'metadata' % baiscally returns self, its here since this way I can do "downcasting" e.g. call md=get(Obj,'MetaData') and get the MetaDat object no matter if Obj if of MetaData class or Task.
            varargout{i}=md;
        case 'collections' % returns all the collection this image is part of
            varargout{i}=md.InCollection;
        case 'imagetype' % a tag that describes what the image is (e.g. row, segmented, labeled, etc.)
            varargout{i}=md.ImageType;
        case 'filename' % the file name of the image, should include the entire path fo the image. 
            varargout{i}=md.ImageFileName;
        case 'creationdate' % Timestamp of the time when the image first created.
            varargout{i}=md.CreationDate;
        case 'lastchangedate' % Timestamp of the time when the image was last written using writeTiff. 
            varargout{i}=md.LastChangeDate;
        case 'description' % free text regarding the image
            varargout{i}=md.Description;
        case 'pixeltype' % If it uint16 (default) or anything else 
            varargout{i}=md.PixelType;
        case 'bitdepth' % how many gray levels there are? usually graylevels are in 2^n so this is n. basically its log2(#graylevels)
            varargout{i}=str2double(md.BitDepth);
        case 'pixelsize' % the conversion of the pixel size to real length, e.g. micrometers in the x (columns) dimensions. If its a scalar it represnets the xy pixel size, otherwise its [x y z]
            varargout{i}=str2arr(md.PixelSizeX);
        case 'channels' % A cell array of channels names, e.g. GFP, Cy3, etc.
            % transform the string into a cell array
            str = md.Channels;
            % remove bracets and break into multi line
            str = regexprep(regexprep(str,'[{}]',''),',','\n');
            % return the cell array
            varargout{i}=textscan(str,'%s');
        case 'channeldescription' %  A hash table (struct) where each channel is a key (field name) and there is freedom as to the value. Could na a number, a char or additional struct with several keys. Also doesn't have to be the same to all channels
            % we use str2arr to convert string into struct
            varargout{i}=str2arr(md.ChannelDescription);
        case 'dimensionorder' % the image is 5D. This provides a mapping for dimensions 3-5 and Z, C and T.
            varargout{i}=md.DimensionOrder;
        case 'dimensionsize' % the image is 5D, what are the sizes of the last three dimensions. 
            varargout{i}=str2arr(md.DimensionSize);
        case 'qdata' % returns a struct array with ALL the quantitative data about the image. See also getQ,setQ,addQ to get specific types of data
            for j=1:length(md.Image.Qdata)
                md.Qdata(j).Value=str2arr(md.Image.Qdata(j).Value);
            end
            varargout{i}=md.Image.Qdata;
        case 'timepointqdata' % returns a cell array of struct array (one cell for each timeslice) for the qdata struct for timepoints
            varargout{i}={md.TimePoint(:).Qdata};
        case 'planenum' % return the overall number of plane that would be in the mutli-plane tiff. Basically its prod(dimsize) ? 
            varargout{i}=prod(get(md,'dimensionsize'));
            
        case 'binning' % Return the binning used. It uses a methods to reduce unnecessary duplication and provide a more intuitive value for cases where otherwise a lot if unnecessary duplication would occur. The reduction of duplication is as follow: <br><br> If only single value of binning used for all channels, z-planes and timepoints -  returns a scalar. <br> If binning was the same for all timepoints and z-planes but different for different chanels returns a 1D ROW vector with size equal to the number of channels. <br> If binning was the same for all timepoints and channels but differet in different z-plane than returns a 1D col vector. <br>  If binning was the same for all timepoints but different for different z-planes AND channels returns a 2D matrix (Rows for channels, columns for Z-planes). <br> Finally, if binning was different in different timepoints, will return a cell array where in each cell the rules are as above. Note that in each timepoint there could be a different number of Z-planes, and different channels and also that in some cases there would be the same (cell will have a scalar) and some they won't, cell will be a vector or a matrix. 
            cl_in=str2arr({md.TimePoint(:).Binning});
            varargout{i}=reduceInput(cl_in);
        case 'exposuretime' % return the exposure time used. Uses method for input reduction, see Binning attribute for details. 
            cl_in=str2arr({md.TimePoint(:).ExposureTime});
            varargout{i}=reduceInput(cl_in);
        case 'stagex' % return the X-position of the stage when the image was captured. Uses method for input reduction, see Binning attribute for details. 
            cl_in=str2arr({md.TimePoint(:).StageX});
            varargout{i}=reduceInput(cl_in);
        case 'stagey' % return the Y-position of the stage when the image was captured. Uses method for input reduction, see Binning attribute for details. 
            cl_in=str2arr({md.TimePoint(:).StageY});
            varargout{i}=reduceInput(cl_in);
        case 'stagez' % Returns the Z-position of the stage when the image was captured. Uses method for input reduction, see Binning attribute for details.  rules. 
            cl_in=str2arr({md.TimePoint(:).StageZ});
            varargout{i}=reduceInput(cl_in);
        case 'channelidx' %TODO: add channelidx for each timepoint
            
        case 'acqtime' % A list of the acquisition timepoints. Units are in Matlab's numeric date number internal representation is in datestr(now,0)
            varargout{i}=datenum({md.TimePoint(:).AcqTime}); 
        case 'timepointnum' % the number of timepoints there are
            varargout{i}=length(md.TimePoint);
        case 'displaymode' % provides information on how to display the image. is it displayed, is it RGB, GRAY, JET
            varargout{i}=md.DisplayOptions.DisplayMode;
        case 'displaylevels' % the levels [min max] to show the image in. 
            varargout{i}=str2arr(md.DisplayOptions.Levels);
        case 'displaychannels' % which channels to display
            varargout{i}=str2arr(md.DisplayOptions.Channels);
        case 'displayroi' % If only a subset of the image needs diplaying, these are the indexes for it. 
            varargout{i}=str2arr(md.DisplayOptions.ROI);
        case 'xml' % a dump of all the metadata in an xml format. 
            varargout{i}=['<III>' struct2xml(struct(md)) '</III>'];
        otherwise
            error('attribute %s is not part of MetaData properties interface',varargin{i});
    end
end

           
%%%%%%%%%%%%%%% private accessory functions
function cl_out=reduceInput(cl_in)
% returned a reduced matrix mat such that any dimension which is only a
% duplication is reduced to singletom. If after reduction mat is 0 / 1 D than 
% it also squeezes since its obvious which dimension the variability is in


cl_out=cell(size(cl_in));
diffFlag=0;
for ii=1:length(cl_in)
    % now check for each cell few possibilities

    % if values are all the same, return scalar
    if range(cl_in{ii}(:)) == 0
        cl_out{ii}=cl_in{ii}(1);
        % if values are the same for all z-stack (rows)
        % return a single row
    elseif sum(range(cl_in{ii})==0) == size(cl_in{ii},2)
        cl_out{ii}=cl_in{ii}(1,:);

        % if values are the same for all channels (cols)
        % return a single col
    elseif sum(range(cl_in{ii}')==0) == size(cl_in{ii},1)
        cl_out{ii}=cl_in{ii}(:,1);
    else
        cl_out{ii}=cl_in{ii};
    end

    % check if different from different timepoint
    if ii > 1 && ~isequal(cl_out{ii-1},cl_out{ii})
        diffFlag=1;
    end
end

if ~diffFlag
    cl_out=cl_out{1};
end



