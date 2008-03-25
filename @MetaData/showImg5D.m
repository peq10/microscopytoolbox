function showImg5D(md,pth,img,hFig)
%SHOWIMG opens a GUI that is useful in looking at 5D images 
%
% Calling arguments: 
% showImg(md,pth) -     show img with md metadata
%                       if img is empty  or missing, will read it from disk
%
% showImg(...,hFig) - hFig is the figure number to show image in

%% set argin defaults
if ~exist('pth','var') || isempty(pth)
    pth='';
end

if ~exist('img','var') || isempty(img)
    img=readTiff(md,pth);
end

if ~exist('hFig','var') 
    hFig=figure;
end

%% Init all kind of things

% variables used for icons
plyicon=[]; pauseicon=[]; zmicon=[]; dsticon=[]; panicon=[];
defIcons;

% start with first t and z
t=1;
z=1;

% timer handle
hTimerText=[];

PlaybackSettingsData.ZT='T';
PlaybackSettingsData.FPS=5;
PlaybackSettingsData.Loop='Yes';
PlaybackSettingsData.ShowTimer='Yes';


chnls=get(md,'Channels');
chnlnum=length(chnls);

% check that img is in 0-1 range
if max(img(:)) > 1
    img=mat2gray(img,[0 2^get(md,'bitdepth')]);
end

%% display info from md
dispChannles=get(md,'displaychannels');

%% set up figures etc.
figure(hFig)
clf

if ~exist('img','var') || isempty(img)
    img=readTiff(md);
end

%  Make sure that image is in XYCZT format 
switch get(md,'DimensionOrder')
    case 'XYZTC'
        dimordr=[1 2 4 5 3];
    case 'XYZCT'
        dimordr=[1 2 5 3 4];
    case 'XYTZC'
        dimordr=[1 2 5 3 4];
    case 'XYTCZ'
        dimordr=[1 2 5 3 4];
    case 'XYCTZ'
        dimordr=[1 2 5 3 4];
    case 'XYCZT'
        dimordr=1:5;
    otherwise
        error('Unsupported dimension order : %s',get(md,'DimensionOrder'))
end
img=permute(img,dimordr);


set(hFig,'Toolbar','none','Menubar','none','name',get(md,'filename'),...
         'position',[350 200 800*size(img,2)/size(img,1) 800],...
         'CloseRequestFcn',@closeFig);
hAxes=axes('position',[0 0.1 1 0.9],'xtick',[],'ytick',[]);

% those handles will be definded later, this "declares" them.
hImg=[];

%% Construct the uicontrols - sliders panel
% Z slider
hZTpnl=uipanel('position',[0 0 0.4 0.1 ]);

hPlaybackSettings=uicontrol(hZTpnl,'style','pushbutton','string','Settings','units','normalized','position',[0.01  0.48 0.18 0.5],...
                                                               'callback',@PlaybackSettings);
hPlayback=uicontrol(hZTpnl,'style','togglebutton','cdata',pauseicon,'units','normalized','position',[0.05  0 0.1 0.5],...
                                                               'callback',@Playback);                                                           

hZslider=uicontrol(hZTpnl,'style','slider','units','normalized','position',[0.2 0.05 0.65 0.3],...
                                   'callback',@zSlider_callback,'min',0.999,'max',size(img,4),'value',1,'SliderStep',[1/size(img,4) 1/size(img,4)]);
hZsliderBox=uicontrol(hZTpnl,'style','edit','units','normalized','position',[0.85 0.05 0.15 0.3],...
                                        'callback',@zSliderBox_callback,'string','1');
hZsliderLabel=uicontrol(hZTpnl,'style','text','string','Z','units','normalized','position',[0.95  0.05 0.05 0.3],'fontweight','bold');


% T slider
hTslider=uicontrol(hZTpnl,'style','slider','units','normalized','position',[0.2 0.5 0.65 0.3],...
                                   'callback',@tSlider_callback,'min',0.999,'max',size(img,5),'value',1,'SliderStep',[1/size(img,5) 1/size(img,5)]);
hTsliderBox=uicontrol(hZTpnl,'style','edit','units','normalized','position',[0.85 0.5 0.15 0.3],...
                                        'callback',@tSliderBox_callback,'string','1');
hTsliderLabel=uicontrol(hZTpnl,'style','text','string','T','units','normalized','position',[0.95  0.55 0.05 0.3],'fontweight','bold');

                                              
%% panel for all level buttons

hLvl=uipanel('position',[0.4 0 0.4 0.1]);
chnldes=get(md,'channeldescription');

% change missing descriptions into the filed 
for ii=1:length(chnls)
    if isempty(chnldes.(chnls{ii}))
        chnldes.(chnls{ii})=chnls{ii};
    end
end

[bla,dispchnlIdx]=ismember({dispChannles.Channel(:).Name},chnls);

for c=1:chnlnum
    hChnlLvl(c).label=uicontrol(hLvl,'style','text','string',chnldes.(chnls{c}),'units','normalized',...
                                     'FontWeight','bold','fontsize',12,'position',[(c-1)/chnlnum 0.7 c/chnlnum 0.3],...
                                     'ForegroundColor',dispChannels.Channel(dispchnlIdx).Hue);
    hChnlLvl(c).checkbox=uicontrol(hLvl,'style','checkbox','callback',@updateImage,'Value',1,'units','normalized',...
                                        'position',[(c-1)/chnlnum 0.5 c/chnlnum 0.2]);
    hChnlLvl(c).contrast=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast',...
                                        'position',[(c-1)/chnlnum 0.26 c/chnlnum 0.22],...
                                        'tag',chnldes.(chnls{c}),'callback',@setContrast);
    hChnlLvl(c).clr=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast',...
                                   'position',[(c-1)/chnlnum 0.01 c/chnlnum 0.22],...
                                   'tag',chnldes.(chnls{c}),'callback',@setColor);
end
                               
%% Save and zoom and pixel info panel

hSaveZoomPnl=uipanel('position',[0.8 0 0.2 0.1]);

% hPixelInfo is created in updateImage function
hSaveBtn=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','string','Save',...
                                'callback',@saveDisplaySettings,'position',[0.01 0.41 0.3 0.38]);
hShowCollBtn=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','string','Collections','callback',@drawCollections_callback,...
                                                          'position',[0.33 0.41 0.3 0.38],'fontsize',8);
                                                      
hAddQdata=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','string','Qdata','callback',@addQdata_callback,...
                                                          'position',[0.66 0.41 0.3 0.38],'fontsize',8);
                                                       
                                                    
hZoomBtn=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','cdata',zmicon,'callback',@ZoomImg,...
                                                        'position',[0.01 0.01 0.3 0.3]);
hPanBtn=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','cdata',panicon,'callback',@PanImg,...
                                                        'position',[0.33 0.01 0.3 0.3]);
hDistToolBtn=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','cdata',dsticon,'callback',@AddDistTool,...
                                                        'position',[0.66 0.01 0.3 0.3]);

%% upate the image
updateImage;

%% That's it - from down here are all the definitions of action using nested functions

    function updateImage(hObject,events) %#ok I don't need events
        %display an image based on current settings
        axis(hAxes);
        hImg=imagesc(rgb);
        set(hAxes,'xlim',roi(1:2),'ylim',roi(3:4),'xtick',[],'ytick',[]);
               
        %% add timer
%         delete(hTimerText);
        TimeStamps=get(md,'acqtime');
        TimeStamps=(TimeStamps-min(TimeStamps))*1440;
        tmpx=get(hAxes,'xlim');
        tmpy=get(hAxes,'ylim');
        
        TimerPos=[(tmpx(2)-tmpx(1))*0.1+tmpx(1) (tmpy(2)-tmpy(1))*0.1+tmpy(1)];
        text(TimerPos(1),TimerPos(2),sprintf('% 5.2f',TimeStamps(t)),'color','w','fontsize',20);
        
    end

    function setContrast(hObject,events) %#ok event is needed for callbacks
        % first only show a single channel
        chnlToChange=get(hObject,'tag');
        chnl_ix=find(strcmp(chnls,chnlToChange));
        axes(hAxes);
        hImg=imagesc(img(:,:,chnl_ix));
        colormap gray
        set(hAxes,'xtick',[],'ytick',[],'clim',img_levels(chnl_ix,:));
        uiwait(imcontrast(hImg));
        
        % change the md display5D property
        img_levels(chnl_ix,:)=get(hAxes,'Clim');
        % the chanel that I care about is:
        imgadj=imadjust(img(:,:,chnl_ix),img_levels(chnl_ix,:));
        rgb=makeRGB;
        
        % that's it, update the image
        updateImage;
        
    end
 
    function zSlider_callback(hObject,events) %#ok event is needed for callbacks
        z = round(get(hObject, 'Value'));
        set(hZsliderBox,'string',num2str(z));
        updateTZ;
    end

    function zSliderBox_callback(hObject,events) %#ok event is needed for callbacks
        z=str2double(get(hObject,'string'));
        z=max(z,get(hZslider,'Min'));
        z=min(z,get(hZslider,'Max'));
        set(hZsliderBox,'String',num2str(z));
        set(hZslider,'value',z);
        updateTZ;
    end

    function tSlider_callback(hObject,events) %#ok I don't need events
        t = round(get(hObject, 'Value'));
        set(hTsliderBox,'string',num2str(t));
        updateTZ;
    end

    function tSliderBox_callback(hObject,events) %#ok I don't need events
        t=str2double(get(hObject,'string'));
        t=max(t,get(hTslider,'Min'));
        t=min(t,get(hTslider,'Max'));
        set(hTsliderBox,'String',num2str(t));
        set(hTslider,'value',t);
        updateTZ;
    end

    function updateTZ
        hndls=[hRchnlCombo hGchnlCombo hBchnlCombo hGrchnlCombo];
        for i=1:4
            img_ix=get(hndls(i),'value')-1;
            if img_ix==0
                rgbg(:,:,i)=zeros(size(rgbg(:,:,1)));
            else
                rgbg(:,:,i)=imadjust(img(:,:,get(hndls(i),'value')-1,z,t),rgbg_levels(i,:));
            end
        end
        updateImage;
    end

    function closeFig(hObject,events)
%         button = questdlg('save display setting for this image?');
%         switch button
%             case 'Yes'
%                 saveDisplaySettings(hObject,events);
%                 delete(hObject)
%             case 'No'
%                 delete(hObject)
%             case 'Cancel'
%         end
    end

    function saveDisplaySettings(hObject,events) %#ok<INUSD>
        %TODO
        filename=[fullfile(pth,get(md,'filename')) '.tiff'];
        if isempty(filename) || ~exist(filename,'file')
            button = questdlg('Image does not have a filename (probably was never saved) do you really want to save it?');
            if sum(ismember(button,{'No','Cancel'})), return, end
        end
        
        % orginize attributes
        hndls=[hRchnlCombo hGchnlCombo hBchnlCombo hGrchnlCombo];
        
        for i=1:4, dspchnls(i)=get(hndls(i),'value')-1; end
        
        % add attributes to md
        md=set(md,'displaylevels',rgbg_levels,...
                          'displaychannels',dspchnls,...
                          'displaymode',get(get(hBtnGrp,'SelectedObject'),'String'),...
                          'displayroi',roi);
        updateTiffMetaData(md,pth);
    end

    function PlaybackSettings(hObject,events) %#ok<INUSD>
        pos=get(hFig,'position');
        hQuestioneer=figure;
        set(hQuestioneer,'position',[pos(1)+100,pos(2)+100,200,200],...
                         'Toolbar','none','Menubar','none','name','Playback Setting');
        
        % Set up all the uicontrols for the playback settigns
        % ZT
        hZTlabel=uicontrol('Style','text','string','Dimension','fontsize',16,'units','normalized','Position',[0 0.8 .4 .2])
        hBtnGrp_ZT = uibuttongroup('parent',hQuestioneer,'visible','off','Position',[0.4 0.8 .6 .2]);
        hBtnT = uicontrol('Style','Radio','String','T','units','normalized','pos',[0 0.5 1 0.33],'parent',hBtnGrp_ZT,'HandleVisibility','off');
        hBtnZ= uicontrol('Style','Radio','String','Z','units','normalized','pos',[0 0.5 1 0.33],'parent',hBtnGrp_ZT,'HandleVisibility','off');
        set(hBtnGrp_ZT,'Visible','on','SelectedObject',findobj(hQuestioneer,'string',PlaybackSettingsData.ZT));

        %Loop
        hLooplabel=uicontrol('Style','text','string','Loop','fontsize',16,'units','normalized','Position',[0 0.6 .4 .2])
        hBtnGrp_Loop = uibuttongroup('parent',hQuestioneer,'visible','off','Position',[0.4 0.8 .6 .2]);
        hBtnT = uicontrol('Style','Radio','String','Yes','units','normalized','pos',[0 0.5 1 0.33],'parent',hBtnGrp_Loop,'HandleVisibility','off');
        hBtnZ= uicontrol('Style','Radio','String','No','units','normalized','pos',[0 0.5 1 0.33],'parent',hBtnGrp_Loop,'HandleVisibility','off');
        set(hBtnGrp_Loop,'Visible','on','SelectedObject',findobj(hQuestioneer,'string',PlaybackSettingsData.Loop));
             
        % FPS
        hFPSlabel=uicontrol('Style','text','string','Loop','fontsize',16,'units','normalized','Position',[0 0.6 .4 .2])             
                     
        uiwait(hQuestioneer);
        
        

    end

    function Playback(hObject,events); %#ok I don't need events
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed-take approperiate action
            set(hObject,'Cdata',plyicon)
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed-take appropriate action
            set(hObject,'Cdata',pauseicon)
        end
        %TODO
    end

    function ZoomImg(hObject,events); %#ok I don't need events
        if isempty(hImg), return, end %only works if image is defined
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Turn off panning (if active)
            set(hPanBtn,'value',get(hPanBtn,'Min'));
            zoom on 
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed-take appropriate action
            zoom off
        end
    end

    function PanImg(hObject,events); %#ok I don't need events
        if isempty(hImg), return, end %only works if image is defined
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % turn off zooming 
            set(hZoomBtn,'value',get(hZoomBtn,'Min'));
            pan on 
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed-take appropriate action
            pan off
        end
    end

    function AddDistTool(hObject,events); %#ok I don't use input argument, but callback needs them
         if isempty(hImg), return, end %only works if image is defined
         imdistline(hAxes);
    end

    function addQdata_callback(hObject,events) %#ok<INUSD>
        hGetQdataFig=figure;
        set(hGetQdataFig,'Toolbar','none','Menubar','none','position',[400 400 300 100],'Name','Add Qdata');
        uicontrol('Style','Text','units','normalized','position',[0.01 0.66 0.25 0.25],'string','Type');
        hQdataType=uicontrol('style','Edit','units','normalized','position',[0.01 0.1 0.25 0.4]);

        uicontrol('Style','Text','units','normalized','position',[0.33 0.66 0.25 0.25],'string','Value');
        hQdataValue=uicontrol('style','Edit','units','normalized','position',[0.33 0.1 0.25 0.4]);

        uicontrol('Style','pushbutton','units','normalized','position',[0.65 0.4 0.25 0.3],'string','Add','callback',@addQdataButton_callback);

        function addQdataButton_callback(hObject,events) %#ok<INUSD>
            Qdata.QdataType=get(hQdataType,'String');
            Qdata.Value=str2double(get(hQdataValue,'String'));
            Qdata.QdataDescription='';
            set(hQdataType,'String','');
            set(hQdataValue,'String','');
            NewQdata=[get(md,'Qdata'); Qdata];
            md=set(md,'Qdata',NewQdata);
        end

    end
  
    function defIcons
        plyicon =[...
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8
            3    3    3    8    8    8    8    8    8    8    8    8    8    8    8    8
            2    6    6    3    3    8    8    8    8    8    8    8    8    8    8    8
            2    4    4    6    6    3    3    8    8    8    8    8    8    8    8    8
            2    4    4    4    4    6    6    3    3    8    8    8    8    8    8    8
            2    4    4    4    4    4    4    6    6    3    3    8    8    8    8    8
            2    4    4    4    4    4    4    4    4    6    6    3    3    8    8    8
            2    4    4    4    4    4    4    4    4    4    4    4    4    3    3    8
            2    4    4    4    4    4    4    4    4    5    5    3    3    7    7    7
            2    4    4    4    4    4    4    5    5    3    3    7    7    7    7    8
            2    4    4    4    4    5    5    3    3    7    7    7    7    8    8    8
            2    4    4    5    5    3    3    7    7    7    7    8    8    8    8    8
            3    5    5    3    3    7    7    7    7    8    8    8    8    8    8    8
            3    3    3    7    7    7    7    8    8    8    8    8    8    8    8    8
            8    8    7    7    7    8    8    8    8    8    8    8    8    8    8    8
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8];
        plyicon=ind2rgb(plyicon,gray(8));
        
        pauseicon=[...
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    4    4    4    4    4    4    4    4    4    4    4    4    8    8
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8
            8    8    8    8    8    8    8    8    8    8    8    8    8    8    8    8];
        pauseicon=ind2rgb(pauseicon,gray(8));
        
        zmicon =[...
            4    4    4    4    0    0    0    0    4    4    4    4    4    4    4    4
            4    4    0    0    3    1    1    4    0    0    4    4    4    4    4    4
            4    0    4    1    1    1    1    4    4    4    0    4    4    4    4    4
            4    0    4    1    1    0    0    4    4    4    0    4    4    4    4    4
            0    4    4    4    4    0    0    4    4    4    4    0    4    4    4    4
            0    4    4    0    0    0    0    0    0    4    4    0    4    4    4    4
            0    4    4    0    0    0    0    0    0    4    4    0    4    4    4    4
            0    4    4    4    4    0    0    4    4    4    4    0    4    4    4    4
            4    0    4    4    4    0    0    4    4    4    0    4    4    4    4    4
            4    0    4    4    4    4    4    4    4    4    0    4    4    4    4    4
            4    4    0    0    4    4    4    4    0    0    2    2    4    4    4    4
            4    4    4    4    0    0    0    0    4    4    2    2    2    4    4    4
            4    4    4    4    4    4    4    4    4    4    4    2    2    2    4    4
            4    4    4    4    4    4    4    4    4    4    4    4    2    2    2    4
            4    4    4    4    4    4    4    4    4    4    4    4    4    2    2    4
            4    4    4    4    4    4    4    4    4    4    4    4    4    4    4    4];
        zmicon=ind2rgb(zmicon,gray(8));
        
        dsticon=[...
            2    2    5    5    5    5    5    5    5    5    5    5    5    5    5    5
            2    4    2    5    5    5    5    5    5    5    5    5    5    5    5    5
            5    2    4    2    5    5    5    5    5    5    5    5    5    5    5    5
            5    5    2    3    2    5    5    5    5    5    5    5    5    5    5    5
            5    5    5    2    4    2    5    5    5    5    5    5    5    5    5    5
            5    5    5    5    2    3    2    5    5    5    5    5    5    5    5    5
            5    5    5    5    5    2    3    2    5    5    5    5    5    5    5    5
            5    5    5    5    5    5    2    4    2    5    5    5    5    5    5    5
            5    5    5    5    5    5    5    2    4    2    5    5    5    5    5    5
            5    5    5    5    5    5    5    5    2    3    2    5    5    5    5    5
            5    5    5    5    5    5    5    5    5    2    4    2    5    5    5    5
            5    5    5    5    5    5    5    5    5    5    2    4    2    5    5    5
            5    5    5    5    5    5    5    5    5    5    5    2    3    2    5    5
            5    5    5    5    5    5    5    5    5    5    5    5    2    4    2    5
            5    5    5    5    5    5    5    5    5    5    5    5    5    2    4    2
            5    5    5    5    5    5    5    5    5    5    5    5    5    5    2    2];
         dsticon=ind2rgb(dsticon,gray(8));
         
         panicon=[...
             129  129  129  129  129  129  129    0    0  129  129  129  129  129  129  129
             129  129  129    0    0  129    0  215  215    0    0    0  129  129  129  129
             129  129    0  215  215    0    0  215  215    0  215  215    0  129  129  129
             129  129    0  215  215    0    0  215  215    0  215  215    0  129    0  129
             129  129  129    0  215  215    0  215  215    0  215  215    0    0  215    0
             129  129  129    0  215  215    0  215  215    0  215  215    0  215  215    0
             129    0    0  129    0  215  215  215  215  215  215  215    0  215  215    0
             0  215  215    0    0  215  215  215  215  215  215  215  215  215  215    0
             0  215  215  215    0  215  215  215  215  215  215  215  215  215    0  129
             129    0  215  215  215  215  215  215  215  215  215  215  215  215    0  129
             129  129    0  215  215  215  215  215  215  215  215  215  215  215    0  129
             129  129    0  215  215  215  215  215  215  215  215  215  215    0  129  129
             129  129  129    0  215  215  215  215  215  215  215  215  215    0  129  129
             129  129  129  129    0  215  215  215  215  215  215  215    0  129  129  129
             129  129  129  129  129    0  215  215  215  215  215  215    0  129  129  129
             129  129  129  129  129    0  215  215  215  215  215  215    0  129  129  129];
         panicon=ind2rgb(panicon,gray(256));
    end

end % main function


%% private sub-functions
function hsv=gray2hsv(gry,clr)

img=repmat(gry,[1 1 3]);
hsv=rgb2hsv(img);
hsv(:,:,1)=clr;
hsv(:,:,2)=1;
end
