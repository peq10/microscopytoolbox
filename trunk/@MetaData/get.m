function varargout=get(md,varargin)
% GET a methos of MetaData class
% md can be a object or array of objects. 
% If md is an array of md, return the data for each md as cell array


global rS; 

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

%% get whatever is asked for...

varargout={};
% get:
% X,Y,Z,Fcs,Channel,ExpTime
for i=1:length(varargin)
    switch lower(varargin{i})
        case 'project.name'
            varargout=[varargout {sub_get(md.xml,'/OME/Project','Name')}];
        case 'dataset.name'
            varargout=[varargout  {sub_get(md.xml,'/OME/Dataset','Name')}];
        case 'image.name'
            varargout=[varargout {sub_get(md.xml,'/OME/Image','Name')}];
        case 'filename'
            filename=[sub_get(md.xml,'/OME/Image','Name') '.tif'];
            varargout=[varargout {filename}];
        case 'fullfilename'
            varargout=[varargout fullfile(get(md,'path'),get(md,'filename'))];
        case 'path'
            pth=[get(rS,'rootFolder') filesep ...
                sub_get(md.xml,'/OME/Project','Name') filesep
                sub_get(md.xml,'/OME/Dataset','Name')];
            varargout=[varargout {pth}];
        case 'objective'
            obj=sub_get(md.xml,'/OME/Instrument/Objective');
            objNA=sub_get(md.xml,'/OME/Instrument/Objective/LensNA');
            objMag=sub_get(md.xml,'/OME/Instrument/Objective/Magnification');
            if iscell(obj)
                objdesc=cells(length(obj),1);
                for j=1:length(obj)
                    objdesc{j}=[obj{j}.Manufacturer ' ' obj{j}.Model ' NA: ' num2str(objNA{j}) 'Mag: '  num2str(objMag{j})];
                end
            else
                objdesc=[obj.Manufacturer ' ' obj.Model ' NA: ' num2str(objNA) 'Mag: '  num2str(objMag)];
            end
            varargout=[varargout {objdesc}];
        case 'experimenter'
            firstname=sub_get(md.xml,'/OME/Experimenter/FirstName','value');
            lastname=sub_get(md.xml,'/OME/Experimenter/LastName','value');
            varargout=[varargout {[firstname ' ' lastname]}];
        case 'experiment'
            varargout=[varargout {sub_get(md.xml,'/OME/Experiment/Description')}];
        case 'pixelsizex'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image','PixelSizeX'))}];
        case 'pixelsizey'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image','PixelSizeY'))}];
        case 'pixelsizez'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image','PixelSizeZ'))}];
        case 'stage.x'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/StageLabel','X'))}];
        case 'stage.y'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/StageLabel','Y'))}];
        case 'stage.z'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/StageLabel','Z'))}];
        case 'channels'
            chnl=sub_get(md.xml,'/OME/Image/ChannelInfo','Name');
            varargout=[varargout {chnl}];
        case 'creationdate'
            varargout=[varargout {sub_get(md.xml,'/OME/Image/CreationDate')}];
        case 'display.r'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/DisplayOptions/RedChannel','ChannelNumber'))}];
        case 'display.g'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/DisplayOptions/GreenChannel','ChannelNumber'))}];
        case 'display.b'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/DisplayOptions/BlueChannel','ChannelNumber'))}];
        case 'display.r_levels'
            minlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/RedChannel','BlackLevel');
            maxlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/RedChannel','WhiteLevel');
            minlvl=str2double(minlvl);
            maxlvl=str2double(maxlvl);
            varargout=[varargout {[minlvl maxlvl]}];
        case 'display.g_levels'
            minlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/GreenChannel','BlackLevel');
            maxlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/GreenChannel','WhiteLevel');
            minlvl=str2double(minlvl);
            maxlvl=str2double(maxlvl);
            varargout=[varargout {[minlvl maxlvl]}];
        case 'display.b_levels'
            minlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/BlueChannel','BlackLevel');
            maxlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/BlueChannel','WhiteLevel');
            minlvl=str2double(minlvl);
            maxlvl=str2double(maxlvl);
            varargout=[varargout {[minlvl maxlvl]}];
        case 'display.gray'
            varargout=[varargout {sub_get(md.xml,'/OME/Image/DisplayOptions/GreyChannel','ChannelNumber')}];
        case 'display.gray_levels'
            minlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/GreyChannel','BlackLevel');
            maxlvl=sub_get(md.xml,'/OME/Image/DisplayOptions/GreyChannel','WhiteLevel');
            minlvl=str2double(minlvl);
            maxlvl=str2double(maxlvl);
            varargout=[varargout {[minlvl maxlvl]}];
        case 'dimension_order'
            varargout=[varargout {sub_get(md.xml,'/OME/Image/Pixels','DimensionOrder')}];
        case 'sizex'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels','SizeX'))}];
        case 'sizey'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels','SizeY'))}];
        case 'sizez'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels','SizeZ'))}];
        case 'sizet'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels','SizeT'))}];
        case 'sizec' 
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels','SizeC'))}];
        case 'firstt'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels/TiffData','FirstT'))}];
        case 'firstz'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels/TiffData','FirstZ'))}];
        case 'firstc'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image/Pixels/TiffData','FirstC'))}];
        case 'xml'
            str=save(md.xml);
            varargout=[varargout {str}];
        case 'exposuredetails'
            varargout=[varargout {md.ExposureDetails}];
        case 'dt'
            varargout=[varargout {str2double(sub_get(md.xml,'/OME/Image','TimeIncrement'))}];
        otherwise
            warning('Throopi:Property:get:MetaData',[varargin{i} ' is no a supported md property']) ; 
    end %switch of varargin{i}
    if length(varargout)>1 && isempty(varargout{end})
         warning(['property:  "' varargin{i}  '"  has no value - does that property exist?']); %#ok
    end
end %main for loop
