function updateTiffMetaData( md,pth )
%UPDATETIFFMETADATA replaces the metadata in a Tiff file

str=get(md,'xml');
filename=fullfile(pth,[get(md,'filename') '.tiff']);

success=true;
cmd=sprintf('tiffset -s ImageDescription "%s" %s',str,filename);
[failed,result] = system(cmd);

if failed
    error('Problem setting up tiff tag - output was: %s',result);
end





