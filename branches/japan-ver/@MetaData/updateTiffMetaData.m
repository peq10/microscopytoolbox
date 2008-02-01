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

str=get(md,'xml');
filename=fullfile(pth,[get(md,'filename') '.tiff']);

%% write the tag str to temp file
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


