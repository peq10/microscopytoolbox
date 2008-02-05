function md = MetaData( varargin )
% MetaData  :  constructor of the MetaData class
%   The MetaData class provides the data structure for all the additional
%   data associsated with an image. It is saved as inside the tiff image as
%   an xml string in the description tagg. 
%
%   few alternative to construct a MetaData objects: 
%      md=MetaData(filename)   -   where filename is I3-tiff or xml
%      md=MetaData;            -   this will construct a skeleton
%      md=MetaData('PropertyName',PropertyValue,...) - Build a default and
%                                                      changes it accordngly


% Here I deal with the case of an empty MetaData object
% All default values are defined in the default.xml file in the private
% folder

if nargin ==0
    md=MetaData('private/default.xml');
    set(md,'CreationDate',datestr(now,0));
    return
end

% Here I deal with the possibility of building it from file
if nargin == 1 && ischar(varargin{1}) && exist(varargin{1},'file')
    filename=varargin{1};
    [pathstr, name, ext] = fileparts(filename); %#ok
    switch ext
        case {'.tif','.tiff'}
            info=imfinfo(filename);
            md=xml2struct(info(1).ImageDescription);
        case {'.xml'}
            md=loadXML(filename);
        otherwise
            error([filename ' is not a supported type, should be tiff, tif or xml']);
    end
    md=md.MD;
    md=class(md,'MetaData');
    return
end

% Here I deal with the case of pairs of properties name and values
if mod(length(varargin),2) %#ok<NODEF>
    error('Must Supply PAIRS of property name, value')
end

md = MetaData; 
for i=1:2:length(varargin)
    md= set(md,varargin{i},varargin{i+1});
end


