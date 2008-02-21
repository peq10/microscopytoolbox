function md = set(md, varargin )
%SET properties of MetaData obect. 
%   can set a only a single object at a time so md must be a single object.
%   varargin must be pairs of attribute / value. 


if ~numel(varargin) || mod(length(varargin),2)
    error('set must get at least one PAIR of proerpty name / values')
end

if length(md)>1
    error('Can only set MetaData objects one by one, please use a loop');
end

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'creationtime' % valid date string
            try
                datenum(varargin{i+1}); 
            catch 
                error('LastChangeDate value must be legitimate date string');
            end
            md.CreationTime=varargin{i+1};
        case 'lastchangetime' % valid date string
            try
                datenum(varargin{i+1}); 
            catch 
                error('LastChangeDate value must be legitimate date string');
            end
            md.LastChangeTime=varargin{i+1};
        case 'collections' % input must be a cell array of chars or a single char. 
            if ~iscell(varargin{i+1}) && ~ischar(varargin{i+1})
                error('for collection input must be a cell array or single char')
            end
            if ischar(varargin{i+1})
                varargin{i+1}={varargin{i+1}};
            end
            % concatenates the collection 
            str='{';
            for ii=1:length(varargin{i+1})
                str=[str ',' varargin{i+1}];
            end
            str=[str '}'];
            md.InCollection=str;
        case 'imagetype' % must be a char
            if ~ischar(varargin{i+1})
                error('Image type must be a char');
            end
            md.ImageType=varargin{i+1};
        case 'filename' % must be a char
            if ~ischar(varargin{i+1})
                error('Image filename must be a char');
            end
            md.ImageFileName=varargin{i+1};
        case 'creationdate' % must be a char and a parsible date format
            % I don't really like using try/catch for input check but since
            % the error is in the catch I think its ok. 
            try
                datenum(varargin{i+1});
            catch
                error('CreationDate could not be parsed by matlab!');
            end
            if ~ischar(varargin{i+1})
                error('CreationDate must be a char');
            end
            md.CreationTime=varargin{i+1};
        case 'lastchangedate' % must be a char and a parsible date format
            % I don't really like using try/catch for input check but since
            % the error is in the catch I think its ok. 
            try
                datenum(varargin{i+1});
            catch
                error('LastChangeDate could not be parsed by matlab!');
            end
            if ~ischar(varargin{i+1})
                error('LastChangeDate must be a char');
            end
            md.LastChangeTime=varargin{i+1};
        case 'description' % must be a char
            if ~ischar(varargin{i+1})
                error('Image Description must be a char');
            end
            md.Description=varargin{i+1};
        case 'pixeltype' % must be one of: (uint8,uint16,logical,single,double)
            if ~ischar(varargin{i+1})
                error('Image PixelType must be a char');
            elseif ~ismember(varargin{i+1},{'uint8','uint16','logical','single','double'})
                error('Image Type must be one of: (uint8,uint16,logical,single,double)');
            end
            md.PixelType=varargin{i+1};
        case 'bitdepth' % must be numeric integer (will be rounded anyway)
            if ~isa(varargin{i+1},'numeric') || ~ismember(numel(varargin{i+1}),[1 3])
                error('Image BitDepth must be single numeric');
            end
            md.BitDepth=num2str(round(varargin{i+1}));
        case 'pixelsize' % must be a numeric scalar (x/y when they are the same) of an array of size 3 ([x y z])
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=1
                error('Image PixelSize must be signle numeric');
            end
            md.PixelSizeX=num2str(varargin{i+1});
        case 'channels' % a cell array of strings (or single string)
            if ~iscell(varargin{i+1}) && ~ischar(varargin{i+1})
                error('Channels must be a cell array or string')
            end
            if ischar(varargin{i+1})
                varargin{i+1}={varargin{i+1}};
            end
            str=['{' varargin{i+1}{1}];
            for ii=2:length(varargin{i+1})
                str=[str ',' varargin{i+1}{ii}];
            end
            str=[str '}'];
            md.Channels=str;
            
            
            % update the DimensionSize metadata
            [ordr,sz]=get(md,'dimensionorder','dimensionsize');
            Tind=strfind(ordr,'T')-2;
            sz(Tind)=length(varargin{i+1});
            md=set(md,'dimensionsize',sz);
            chnls=varargin{i+1};
            % if a channel is missing from channeldescription add it
            % and if channel description has to many fields, remove them
            chnldes=get(md,'channeldescription');
            if isempty(chnldes), chnldes=struct('stam',[]); end
            df=setdiff(varargin{i+1},fieldnames(chnldes));
            for ii=1:length(df)
                chnldes.(df{ii})='';
            end
            chnldes=rmfield(chnldes,setdiff(fieldnames(chnldes),chnls));
            md=set(md,'channeldescription',chnldes);
            
        case 'channeldescription' % must be a single struct with fields subset of get(md,'channels')
            if ~isstruct(varargin{i+1}) && numel(varargin{i+1}) ~=1 
                error('ChannelDescriptoin must be a single struct');
            end
            if ~isempty(setdiff(fieldnames(varargin{i+1}),get(md,'Channels')))
                error('ChannelDescriptoin struct must have Channel names for fields names');
            end
            md.ChannelDescription=arr2str(varargin{i+1});
            
        case 'dimensionorder' % must be a char and one of the following: {'XYTCZ', 'XYTZC', 'XYZTC', 'XYZCT', 'XYCZT', 'XYCTZ'} 
            if ~ischar(varargin{i+1}) 
                error('Image DimensionOrder must be a char');
            end
            if ~ismember(varargin{i+1},{'XYTCZ', 'XYTZC', 'XYZTC', 'XYZCT', 'XYCZT', 'XYCTZ'})
               error('Dimension Order must be one of {XYTCZ, XYTZC, XYZTC, XYZCT, XYCZT, XYCTZ}'); 
            end
            md.DimensionOrder=varargin{i+1};
        case 'dimensionsize' % Image DimensionSize must be numeric with numel smaller or euqal to3
            if ~isnumeric(varargin{i+1}) || numel(varargin{i+1}) > 3
                error('Image DimensionSize must be numeric with numel <=3');
            end
            md.DimensionSize=arr2str(varargin{i+1});
        case 'imgheight' % ImgHeight must be numeric scalar
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~= 1
                error('ImgHeight must be numeric scalar')
            end
            md.ImgHeight=num2str(varargin{i+1});
        case 'imgwidth' % ImgWidth must be numeric scalar
            if ~isa(varargin{i+1},'numeric') ||  numel(varargin{i+1})~= 1
                error('ImgWidth must be numeris and <= 3D')
            end
            md.ImgWidth=num2str(varargin{i+1});
            
            
        %% Timepoint related attributes    
        case 'acqtime' % must be numeric in matlab datenum units, will be converted to a row vector
            if ~isa(varargin{i+1},'numeric') || length(size(varargin{i+1})) > 3
                error('Timepoint must be numeric')
            end
            tp=varargin{i+1};
            % If I'm speccifying more timepoints that exist, use the last
            % timepoint that exist as the default to define the rest
            crnt_tp_num=get(md,'timepointnum');
            for ii=1:length(tp)
                if ii>crnt_tp_num
                    md.TimePoint(ii)=md.TimePoint(crnt_tp_num);
                end
                md.TimePoint(ii).AcqTime=datestr(tp(ii),0);
            end
            [ordr,sz]=get(md,'dimensionorder','dimensionsize');
            % update the DimensionSize metadata
            Tind=strfind(ordr,'T')-2;
            sz(Tind)=length(tp);
            md=set(md,'dimensionsize',sz);
            
        case 'binning' % must be: 1. numeric and smaller or equal to 3D OR cell array where each cell is a 1-2D numeric, for cases where its 2D its [ZxC] z-planes for rows and channels for columns
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)  
                error('Binning must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).Binning=arr2str(output{ii});
            end

        case 'stagex' % must be: 1. numeric and smaller or euqal to 3D OR cell array where each cell is a 1-2D numeric, for cases where its 2D its [ZxC] z-planes for rows and channels for columns
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)  
                error('StageX must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).StageX=arr2str(output{ii});
            end
            
        case 'stagey' % must be: 1. numeric and smaller or euqal to 3D OR cell array where each cell is a 1-2D numeric, for cases where its 2D its [ZxC] z-planes for rows and channels for columns
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)  
                error('StageY must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).StageY=arr2str(output{ii});
            end
        case 'stagez' % must be: 1. numeric and smaller or euqal to 3D OR cell array where each cell is a 1-2D numeric, for cases where its 2D its [ZxC] z-planes for rows and channels for columns
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)  
                error('StageZ must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).StageZ=arr2str(output{ii});
            end
            
            % update the DimensionSize metadata
            Zind=strfind(ordr,'Z')-2;
            sz(Zind)=length(inpt);
            md=set(md,'dimensionsize',sz);
            
        case 'exposuretime' % must be: 1. numeric and smaller or euqal to 3D OR cell array where each cell is a 1-2D numeric, for cases where its 2D its [ZxC] z-planes for rows and channels for columns
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)  
                error('Exposure Time must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).ExposureTime=arr2str(output{ii});
            end
        case 'exposure'
            if ~iscell(varargin{i+1}) &&  ( ~isa(varargin{i+1},'numeric') || ndims(varargin{i+1}) > 3)
                error('Exposure Time must be cell array OR a numeric with upto <= 3D')
            end
            
            [sz,ordr,tpn]=get(md,'dimensionsize','dimensionorder','timepointnum');
            inpt=varargin{i+1};
            output=repinput(sz,ordr,inpt);
            for ii=1:tpn
                md.TimePoint(ii).ExposureTime=arr2str(output{ii});
            end
        case 'timepointqdata' % a Qdata struct (array), see Qdata,  or a cell array of Qdata struct (arrays) with the same number of cells as there are timepoits!
            if istruct(varargin{i+1})
                varargin{i+1}={varargin{i+1}};
            end
            if ~iscell(varargin{i+1}) 
                error('TimePoint Qdata must be a struct or a cell array');
            end
            if length(varargin{i+1}) ~= length(md.Timepoint)
                error('TimePoint Qdata must be the same length as Timpoints');
            end
            for ii=1:length(varargin{i+1});
                md.TimePoint(ii).Qdata=formatQdata(varargin{i+1}{ii}); 
            end
            
            
        case 'qdata' % must be a struct array with fields: {'QdataType';'Value'; 'Label'; 'QdataDescription'}
            md.Qdata=formatQdata(varargin{i+1});
            
        % attributes related only to how to diaply the images  
        case 'displayfps' % nums be numeric
            if ~isnumeric(varargin{i+1})
                error('FPS must be numeric');
            end
            md.DisplayOptions.FPS=num2str(varargin{i+1});
        case 'displaymode' % one of: 'Gray','RGB','Comp' (Comp is composite)
            if ~ischar(varargin{i+1}) || ~sum(ismember(varargin{i+1},{'Gray','RGB','Comp'}))
                error('Unsupported disaply mode - must be Gray / RGB / Comp');
            end
            md.DisplayOptions.DisplayMode=varargin{i+1};
        case 'displaylevels' % 'Display levels must be numeric 4 x 2 matrix'
            if ~isa(varargin{i+1},'numeric') || size(varargin{i+1},1)~=4 || size(varargin{i+1},2)~=2
                error('Display levels must be numeric 4 x 2 matrix')
            end
            md.DisplayOptions.Levels=arr2str(varargin{i+1});
        case 'displaychannels' % 'Display channel must be either a 4 element cell array with channel names (or 'None') or a  numeric 4 element vector which references the channel for the Red Green Blue and Gray disaply channels, set 0 for none
            if ~isa(varargin{i+1},'numeric') && ~iscell(varargin{i+1}) || numel(varargin{i+1})~=4 
                error(['Display channel must be a 4 element cell array with channel mames numeric 4 element vector which references the:\n'...
                         'channel for the Red Green Blue and Gray disaply channels, set 0 for none']);
            end
            % if its a cell array, convert it into indexes based on
            % channesl. 
            if iscell(varargin{i+1})
                chnls=get(md,'Channels');
                chnls=[{'None'},chnls];
                [bla,ind]=ismember(varargin{i+1},chnls);
                ind=ind-1;
            else
                ind=varargin{i+1};
            end
            md.DisplayOptions.ChannelIdx=arr2str(ind);
            
        case 'displayroi' % 'Display levels must be numeric 4 element matrix
            if ~isa(varargin{i+1},'numeric') || numel(varargin{i+1})~=4 
                error('Display levels must be numeric 4 element matrix')
            end
            md.DisplayOptions.ROI=arr2str(varargin{i+1});
            
        case 'displaystruct' % input must be a struct - will replace the entire disaply settings.
            if ~isstruct(varargin{i+1})
                error('displaystruct must be a STRUCT (Dah!)');
            end
            md.DisplayOptions=varargin{i+1};
        otherwise
            error('attribute %s is not part of MetaData properties interface',varargin{i});
    end
end

%%%%%%%%%%%%%%%%%%%%%% private accesory functions

function outpt=repinput(sz,ordr,inpt)
% create a cell array the size of number of timepoints and where in each
% cell there is a 2D matrix of size [Zn x Cn] (# z-planes x # channels)
% do this by prelicating as necessary. 

Tind=strfind(ordr,'T')-2;
Zind=strfind(ordr,'Z')-2;
Cind=strfind(ordr,'C')-2;
outpt=cell(1,sz(Tind));
rep=sz([Zind Cind]);
rep(sz([Zind Cind])>1)=1;

for ii=1:sz(Tind)
    if iscell(inpt)
        mat=inpt{ii};
    elseif ndims(inpt) == 3
        mat=inpt(:,:,ii);
    else
        mat=inpt;
    end
    outpt{ii}=repmat(mat,rep);
end

%%%%

function Qdata=formatQdata(Qdata)
% checks for Qdata legality and format is for storage using arr2str on
% every Value field
if ~isstruct(Qdata),
    error('Qdata must be a struct');
end
if ~isequal(fieldnames(Qdata),{'QdataType';'Value'; 'Label'; 'QdataDescription'})
    % test it only a matter of order
    Qdata=orderfields(Qdata,{'QdataType'; 'Value'; 'Label'; 'QdataDescription'});
    % if still not equal, throw an error
    if ~isequal(fieldnames(Qdata),{'QdataType';'Value'; 'Label'; 'QdataDescription'})
        error('Wrong fields for Qdata struct')
    end
end
for j=1:length(Qdata)
    Qdata(j).Value=arr2str(Qdata(j).Value);
end



 
