function updateTiffMetaData( md,pth )
% updateTiffMetaData : replaces the metadata in a Tiff file
%    This methods gets the xml form of the MetaData object md and writes 
%    it in the first plane of the (possible multi-plane) tiff file:
%    [pth filesep get(md,filename))].
%
%    It overwrites any existing metadata information. 
%    TODO: the current implementation doesn't block for write, it should!

%% get the filename & check it
filename=fullfile(pth,get(md,'filename'));
[p,f,ext]=fileparts(filename);
if ~ismember(ext,{'.tif','.tiff'})
    filename=[filename '.tiff'];
end

%% get the XML as string (str) and write it to to temp file
str=get(md,'xml');

%% replace comments using TiffTools (via bio-formats)
loci.formats.TiffTools.overwriteComment(filename,str);

