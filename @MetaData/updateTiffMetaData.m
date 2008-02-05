function updateTiffMetaData( md,pth )
% updateTiffMetaData : replaces the metadata in a Tiff file
%    This methods gets the xml form of the MetaData object md and writes 
%    it in the first plane of the (possible multi-plane) tiff file:
%    [pth filesep get(md,filename))].
%
%    It overwrites any existing metadata information. 
%
%    TODO: Current implementation uses tiffset. This is UGLY and should be replaced
%
%    TODO: the current implementation doesn't block for write, it should!


%% get the filename & check it
filename=fullfile(pth,get(md,'filename'));
[p,f,ext]=fileparts(filename);
if ~ismember(ext,{'.tif','.tiff'})
    filename=[filename '.tiff'];
end

%% get the XML as string (str) and write it to to temp file
str=get(md,'xml');
fid=fopen('MetaDataTemp.tmp','w');
fprintf(fid,'%s',str);
fclose(fid);

cmd=sprintf('tiffset -sf ImageDescription MetaDataTemp.tmp %s',filename);
failed = system(cmd);

if failed
    % wait and try try again
    pause(0.5)
    [failed,result] = system(cmd);
    if failed
        pause(0.5)
        [failed,result] = system(cmd);
    end
    if failed
        error('Problem setting up tiff tag - output was: %s',result);
    end
end


