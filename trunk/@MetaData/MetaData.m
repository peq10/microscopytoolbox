function md = MetaData( varargin )
%METADATAconstructor of the MetaData class
%   few alternative calls: 
%      md=MetaData(filename)   -   where filename is I3-tiff or xml
%      md=MetaData;                -   this will construct a skeleton
%      md=MetaData('PropertyName',PropertyValue,...) - Build a default and
%                                                                              changes it accordngly


% Here I deal with the case of an empty MetaData object
% All default values are defined in the default.xml file in the private
% folder
if nargin ==0
    md=MetaData('private/default.xml');
    return
end

% Here I deal with the possibility of building it from file
if nargin == 1 
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
    md=md.III;
    md=class(md,'MetaData');
    return
end
% Here I deal with the case of pairs of properties name and values
md = MetaData; 
md= set(md,varargin);
