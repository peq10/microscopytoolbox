function updateTiffMetaData( md,pth )
%UPDATETIFFMETADATA replaces the metadata in a Tiff file

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





=======
if failed
    error('Problem setting up tiff tag - output was: %s',result);
end





>>>>>>> .r52
