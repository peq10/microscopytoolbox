function showImg(md,pth,img,catfilename,hFig)
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

if ~exist(catfilename,'var')
    catfilename='showImgPref.txt';
end

h=findobj('tag','pixelinfo');
delete(h);

%% Init all kind of things
% variables used for icons
plyicon=[]; pauseicon=[]; zmicon=[]; dsticon=[]; panicon=[];
defIcons;

% start with first t and z
t=1;
z=1;

fid=fopen(catfilename);
C=textscan(fid,'%s%s%s\n','delimiter',',');
fclose(fid);
Qclicks.keys=C{1};
Qclicks.types=C{2};
Qclicks.labels=C{3};

% timer handle
hTimerText=[];

PlaybackSettingsData.ZT='T';
PlaybackSettingsData.FPS=get(md,'displayfps');
PlaybackSettingsData.Loop='Yes';
PlaybackSettingsData.ShowTimer='Yes';


rgbg=zeros([size(img(:,:,1)) 4]);
allchnls={'Red','Green','Blue','Gray'}; % a list of all channels                                   

% a flag to note what state we are in
compFlag=-1; % -1 never showed an image / 0 rgb-gray image / 1 comp image

% check that img is in 0-1 range
if max(img(:)) > 1
    img=mat2gray(img,[0 2^get(md,'bitdepth')]);
end

%% display info from md
% levels - get from md but if doesn't exist, default is 0-1
rgbg_levels=get(md,'displaylevels'); 
if isempty(rgbg_levels), 
    rgbg_levels=[0 1; 0 1; 0 1; 0 1]; 
end

% get list of possible channels
pos_chnl=[{'none'}; get(md,'Channels')];

%ROI - defaults to whole image
roi=get(md,'displayroi');
if isempty(roi), 
    roi=[0.5 size(img,2)+0.5 0.5 size(img,1)+0.5]; 
end

% Mode - defaults to Gray
initdspmode=get(md,'displaymode');
if isempty(initdspmode), 
    switch length(pos_chnl)
        case {0,1}
            error('Please check that MetaData object md has at least one channel defined with number and content');
        case 2
            initdspmode='Gray';
        case 3
            initdspmode='RGB';
        otherwise
            initdspmode='RGB';
    end
end

% channel Idx - mapping of channels into RGBG layers
chnlIdx=get(md,'ChannelIdx');
if isempty(chnlIdx);
    switch length(pos_chnl)
        case {0,1}
            error('Please check that MetaData object md has at least one channel defined with number and content');
        case 2
            chnlIdx=[1 1 1 2];
        case 3
            chnlIdx=[2 3 1 2];
        otherwise
            chnlIdx=[2 3 4 2];
    end
end

%% transform image dimensionality if needed
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

%% set up figures etc.
figure(hFig)
clf
UserData.md=md;
set(hFig,'Toolbar','none','Menubar','none','name',get(md,'filename'),...
         'position',[350 200 800*size(img,2)/size(img,1) 800],...
         'CloseRequestFcn',@closeFig,'userdata',UserData);
hAxes=axes('position',[0 0.1 1 0.9],'xtick',[],'ytick',[]);
cla
% those handles will be definded later, this "declares" them.
hImg=[];

%% Construct the uicontrols - sliders
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

% red chanel controls
hRchnlLabel=uicontrol(hLvl,'style','text','string','Red','units','normalized','position',[0.01 0.7 0.2 0.3],...
                                        'ForegroundColor','r','FontWeight','bold','fontsize',12);
hRchnlCombo=uicontrol(hLvl,'style','popupmenu','units','normalized','string',pos_chnl,'position',[0.01 0.4 0.2 0.3],...
                                          'callback',@changeChannel,'tag','Red');
hRchnlBtn=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast','position',[0.01 0.05 0.2 0.28],...
                                       'tag','Red','callback',@setContrast);

% green chanel controls
hGchnlLabel=uicontrol(hLvl,'style','text','string','Green','units','normalized','position',[0.21 0.7 0.2 0.3],...
                                        'ForegroundColor','g','FontWeight','bold','fontsize',12);
hGchnlCombo=uicontrol(hLvl,'style','popupmenu','units','normalized','string',pos_chnl,'position',[0.21 0.4 0.2 0.3],...
                                           'callback',@changeChannel,'tag','Green');
hGchnlBtn=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast','position',[0.21 0.05 0.2 0.28],...
                                      'tag','Green','callback',@setContrast);

% blue chanel controls
hBchnlLabel=uicontrol(hLvl,'style','text','string','Blue','units','normalized','position',[0.41 0.7 0.2 0.3],...
                                        'ForegroundColor','b','FontWeight','bold','fontsize',12);
hBchnlCombo=uicontrol(hLvl,'style','popupmenu','units','normalized','string',pos_chnl,'position',[0.41 0.4 0.2 0.3],...
                                           'callback',@changeChannel,'tag','Blue');
hBchnlBtn=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast','position',[0.41 0.05 0.2 0.28],...
                                     'tag','Blue','callback',@setContrast);

% gray chanel controls
hGrchnlLabel=uicontrol(hLvl,'style','text','string','Gray','units','normalized','position',[0.61 0.7 0.2 0.3],...
                                        'ForegroundColor','k','FontWeight','bold','fontsize',12);
hGrchnlCombo=uicontrol(hLvl,'style','popupmenu','units','normalized','string',pos_chnl,'position',[0.61 0.4 0.2 0.3],...
                                           'callback',@changeChannel,'tag','Gray');
hGrchnlBtn=uicontrol(hLvl,'style','pushbutton','units','normalized','string','Contrast','position',[0.61 0.05 0.2 0.28],...
                                       'tag','Gray','callback',@setContrast);

                                   
% Mode radio buttons
hBtnGrp = uibuttongroup('parent',hLvl,'visible','on','Position',[0.81 0 .2 1]);
hBtnGray = uicontrol('Style','Radio','String','Gray','units','normalized','pos',[0 0.66 1 0.33],'parent',hBtnGrp,'HandleVisibility','off');
hBtnRGB= uicontrol('Style','Radio','String','RGB','units','normalized','pos',[0 0.33 1 0.33],'parent',hBtnGrp,'HandleVisibility','off');
hBtnComp = uicontrol('Style','Radio','String','Comp','units','normalized','pos',[0 0 1 0.33],'parent',hBtnGrp,'HandleVisibility','off');
set(hBtnGrp,'SelectionChangeFcn',@updateImage,'Visible','on');
switch initdspmode
    case 'RGB'
        set(hBtnGrp,'SelectedObject',hBtnRGB);
    case 'Comp'
        set(hBtnGrp,'SelectedObject',hBtnComp);
    case 'Gray'
        set(hBtnGrp,'SelectedObject',hBtnGray);
    otherwise
        error('can''t set mode into illegal value')
end

%% Save and zoom and pixel info panel

hSaveZoomPnl=uipanel('position',[0.8 0 0.2 0.1]);

% hPixelInfo is created in updateImage function
hSaveBtn=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','string','Save',...
                                'callback',@saveDisplaySettings,'position',[0.01 0.41 0.3 0.38]);
hShowQdata=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','string','draw','callback',@updateImage,...
                                  'value',1,'position',[0.33 0.41 0.3 0.38],'fontsize',8);
                                                      
hAddQdata=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','string','add',...
                                 'position',[0.66 0.41 0.3 0.38],'fontsize',8,'callback',@keyPress);
                                                       
hZoomBtn=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','cdata',zmicon,'callback',@ZoomImg,...
                                                        'position',[0.01 0.01 0.3 0.3]);
hPanBtn=uicontrol(hSaveZoomPnl,'style','togglebutton','units','normalized','cdata',panicon,'callback',@PanImg,...
                                                        'position',[0.33 0.01 0.3 0.3]);
hDistToolBtn=uicontrol(hSaveZoomPnl,'style','pushbutton','units','normalized','cdata',dsticon,'callback',@AddDistTool,...
                                                        'position',[0.66 0.01 0.3 0.3]);

%% Fill in the channel data and update the image

set(hRchnlCombo,'value',chnlIdx(1));
changeChannel(hRchnlCombo);
set(hGchnlCombo,'value',chnlIdx(2));
changeChannel(hGchnlCombo);
set(hBchnlCombo,'value',chnlIdx(3));
changeChannel(hBchnlCombo);
set(hGrchnlCombo,'value',chnlIdx(4));
changeChannel(hGrchnlCombo);

updateImage;

%% That's it - from down here are all the definitions of action using nested functions

    function updateImage(hObject,events) %#ok I don't need events
        %display an image based on current settings
        if compFlag==0
            roi=[get(hAxes,'xlim') get(hAxes,'ylim')];
        end
        switch get(get(hBtnGrp,'SelectedObject'),'String')
            case 'Gray'
                if compFlag>0
                    cla;
                end
                compFlag=0;
                toshow=4;
                colormap gray;
            case 'RGB'
                if compFlag>0
                    cla;
                end
                compFlag=0;
                toshow=1:3;
            case 'Comp'
                compFlag=1;
                cla
                sz=size(rgbg(:,:,1));
                ind={1:sz(1),1:sz(2); 1:sz(1),sz(2)+1:2*sz(2); sz(1)+1:2*sz(1),1:sz(2); sz(1)+1:2*sz(1),sz(2)+1:2*sz(2)};
                image(zeros([sz*2 3]));
                hold on
                for i=1:3
                    cmp=zeros([sz,3]);
                    cmp(:,:,i)=rgbg(:,:,i);
                    image(ind{i,1},ind{i,2},cmp);
                end
                cmp=repmat(rgbg(:,:,4),[1,1,3]);
                image(ind{4,1},ind{4,2},cmp);
                set(hAxes,'xtick',[],'ytick',[])
                hold off
                return
        end
        
        axis(hAxes);
        hImg=imagesc(rgbg(:,:,toshow));
        hPixelInfo=impixelinfoval(hSaveZoomPnl,hImg);
        set(hPixelInfo,'units','normalized','position',[0 0.8 1 0.2],'tag','pixelinfo');
        set(hAxes,'xlim',roi(1:2),'ylim',roi(3:4),'xtick',[],'ytick',[]);
        
        %% add timer
%         delete(hTimerText);
        TimeStamps=get(md,'acqtime');
        TimeStamps=(TimeStamps-min(TimeStamps))*1440;
        tmpx=get(hAxes,'xlim');
        tmpy=get(hAxes,'ylim');
        
        TimerPos=[(tmpx(2)-tmpx(1))*0.1+tmpx(1) (tmpy(2)-tmpy(1))*0.1+tmpy(1)];
        text(TimerPos(1),TimerPos(2),sprintf('% 5.2f',TimeStamps(t)),'color','w','fontsize',20);
        
        %% add the keypress functionality just in case it get lost during
        %% plotting
        %% add Qdata to the plot
        if get(hShowQdata,'value') == get(hShowQdata,'max')
             overlayAnnotation; 
        end
        
        % update the md userdata
        saveDisplaySettings; % this would also update the md object
        UserData.md=md;
        set(hFig,'userdata',UserData);

        
    end

    function overlayAnnotation(hObject,events) %#ok<INUSD>
        
            qdata=getQdata(md,'click');
            for i=1:length(qdata)
                text(qdata(i).Value(1),qdata(i).Value(2),qdata(i).Label,'color','w');
            end

    end % overlay annotation

    function changeChannel(hObject,events) %#ok I don't need events
        img_ix=get(hObject,'value')-1; % this index the img matrix
        rgbg_ix=find(ismember(allchnls,get(hObject,'tag'))); % this is the channel to show it in
        if img_ix==0
             rgbg(:,:,rgbg_ix)=zeros(size(rgbg(:,:,1))); %#ok<FNDSB>
        else
            rgbg(:,:,rgbg_ix)=imadjust(img(:,:,img_ix,z,t),rgbg_levels(rgbg_ix,:)); %#ok, I know logical indexing is faster, this is easier to understand...
        end
        updateImage;
    end

    function setContrast(hObject,events) %#ok event is needed for callbacks
        % turn off zooming and panning
        set(hZoomBtn,'value',get(hZoomBtn,'min'));
        ZoomImg(hZoomBtn,events);
        set(hPanBtn,'value',get(hPanBtn,'min'));
        PanImg(hPanBtn,events);
        % first only show a single channel
        switch get(hObject,'tag')
            case 'Red'
                if get(hBtnGrp,'SelectedObject')~=hBtnRGB
                    set(hBtnGrp,'SelectedObject',hBtnRGB);
                end
                lvl_ix=1;
                chnl_ix=get(hRchnlCombo,'value')-1;
            case 'Green'
                if get(hBtnGrp,'SelectedObject')~=hBtnRGB
                    set(hBtnGrp,'SelectedObject',hBtnRGB);
                end
                lvl_ix=2;
               chnl_ix=get(hGchnlCombo,'value')-1;
            case 'Blue'
                if get(hBtnGrp,'SelectedObject')~=hBtnRGB
                    set(hBtnGrp,'SelectedObject',hBtnRGB);
                end
                chnl_ix=get(hBchnlCombo,'value')-1;
                lvl_ix=3;

            case 'Gray'
                if get(hBtnGrp,'SelectedObject')~=hBtnGray
                    set(hBtnGrp,'SelectedObject',hBtnGray);
                end
                chnl_ix=get(hGrchnlCombo,'value')-1;
                lvl_ix=4;
        end
        axes(hAxes);
        hImg=imagesc(img(:,:,chnl_ix));
        colormap gray
        set(hAxes,'xtick',[],'ytick',[],'clim',rgbg_levels(lvl_ix,:));
        uiwait(imcontrast(hImg));
        rgbg_levels(lvl_ix,:)=get(hAxes,'Clim');
        % the chanel that I care about is:
        h=findobj(gcf,'style','popupmenu','-and','tag',get(hObject,'tag'));
        img_ix=get(h,'value')-1;
        if img_ix==0, return, end % just in case its 'none'
        rgbg(:,:,lvl_ix)=imadjust(img(:,:,img_ix),rgbg_levels(lvl_ix,:));
        
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
                saveDisplaySettings(hObject,events);
                delete(hObject)
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

    function keyPress(hObject,events) %#ok<INUSD>
        % when a key is pressed and the add Qdata button is pressed 
        % get the next click
        if get(hAddQdata,'value') == get(hAddQdata,'min')
            return
        end
        while get(hAddQdata,'Value') == get(hAddQdata,'max')
            axes(hAxes)
            [x,y,k]=ginput(1); 
            if k==32
                set(hAddQdata,'value',get(hAddQdata,'min'))
                return
            end
            pnt=[x y];
            k=char(k);
            ix=find(strcmp(k,Qclicks.keys));
            if isempty(ix)
                continue
            end
            typ=Qclicks.types{ix};
            lbl=Qclicks.labels{ix};
            switch typ
                case 'click'
                    md=addQdata(md,'type','click','value',pnt,'label',lbl,'description','A user click position and label on an image');
                case 'polygon'
            end
            updateTiffMetaData(md,pth);
            updateImage;
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
