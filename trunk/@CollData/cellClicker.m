function cellClicker(pth,catfilename)
% add Qdata tags of XY location of cells based on user clicks. 

close all
if ~exist('pth','var')
    pth=uigetdir;
end

if ~exist('catfilename','var')
    catfilename=uigetfile;
end

dr=dir(fullfile(pth,'*.tiff'));

cnt=0;
hBar=[];
hPie=[];
hBarLegend=[];
hBtnsPnl=[];
hBtns=[];
md=[];
dispSettings=[];

Qdata=[];

createGui;
next_callback;

    function createGui
        figure(1)
        set(1,'position',[ 25   827   320   262],...
              'Toolbar','none','Menubar','none');
        hPie=subplot('position',[0 0.3 0.5 0.35]);
        hBar=subplot('position',[0.1 0.75 0.8 0.2]);
        hBtnsPnl=uipanel('position',[0 0 1 0.3 ]);
        set(hBar,'Visible','off');
          
          
        hBtns.next = uicontrol(hBtnsPnl,'style','pushbutton',...
                                     'string','Next',...
                                     'units','normalized',...
                                     'position',[0.01  0.2 0.18 0.6],...
                                     'callback',@next_callback);
                                 
        hBtns.prev = uicontrol(hBtnsPnl,'style','pushbutton',...
                                     'string','Prev',...
                                     'units','normalized',...
                                     'position',[0.2  0.2 0.18 0.6],...
                                     'callback',@prev_callback);
                                 
    end


    function next_callback(hObject, eventdata) %#ok<INUSD>
        if strcmp(class(md),'MetaData')
            userdata=get(2,'userdata');
            md=userdata.md;
            updateTiffMetaData(md,pth);
            dispSettings=get(md,'displaystruct');
            newq=get(md,'qdata');
            unqcell=unique({newq(:).QdataType});
            if ~isempty(unqcell{1})
                Qdata=[Qdata; newq(:)];
            end
            PrevMDflag=true;
        else
            PrevMDflag=false;
        end
        cnt=min(cnt+1,length(dr));
        md=MetaData([pth dr(cnt).name]);
        % is a previous md object existed AND it had a display mode (e.g.
        % not default) =
        if PrevMDflag && ~isempty(dispSettings.DisplayMode)
            % flag just says whether there was a previous md object
            md=set(md,'displaystruct',dispSettings);
        end
        refresh_plots
    end

    function prev_callback(hObject, eventdata) %#ok<INUSD>
        cnt=max(cnt-1,1);
        updateTiffMetaData(md,pth);
        md=MetaData([pth dr(cnt).name]);
        refresh_plots
    end

    function refresh_plots
        axes(hPie);
        pie([cnt length(dr)-cnt],[1 0])
        colormap summer
        axes(hBar);
        if ~isempty(Qdata)
            [cellnum,bla,bla,lbl]=crosstab({Qdata.QdataType},{Qdata.Label});
            for jj=1:size(lbl,1)
                for kk=1:size(lbl,2)
                    if isempty(lbl{jj,kk})
                        lbl{jj,kk}='';
                    end
                end
            end
            set(hBar,'Visible','on');
            barh([zeros(size(cellnum')); cellnum']);
            set(hBar,'yticklabel',lbl(:,1))
            hBarLegend=legend(lbl(:,2));
            set(hBarLegend,'position',[0.5 0.3 0.35 0.35])
        end
        showImg(md,pth,[],catfilename,2)
    end


end % main function
