function md=MetaData(filename,n)
% MetaData constructor
% Usage: 
% filename  -  either  .tiff .xml or .ome
% n (optional) - number of array elements to create. 
%
%  Remark: 
%  MetaData in its current implementation uses xmltree, so make sure it exist in the path


%% check input arguments

error(nargchk(0,1,nargin))

if ~ischar(filename)
    error('Filename should be charachter');
end

if ~exist(filename,'file')
    error(['could not find the filename ' filename ' please check']);
end

%% create an array if necessary. 

if nargin==2 && n>1
    for i=1:n
        md(i)=MetaData; 
    end
    return
end

%% read the xml from the tiff/xml file

[pathstr, name, ext] = fileparts(filename);
switch ext
    case {'.tif','.tiff'}
        info=imfinfo(filename);
        xml=xmltree(info(1).ImageDescription);
    case {'.xml','.ome'}
        xml=xmltree(filename);
    otherwise
        error([filename ' is not a supported type, should be tiff, tif ome or xml']);
end

md.ExposureDetailes=[];
md.xml=xml;
md=class(md,'MetaData');