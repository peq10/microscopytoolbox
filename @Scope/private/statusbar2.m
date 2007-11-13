function f=statusbar2(p,p2,f)
% Display two status/progress bars of both primary  
% and secondary  processes and inform about the elapsed 
% as well as the remaining time .
%
% Synopsis:
%
%  f=statusbar2
%     Get all status/progress bar handles.
%
%  f=statusbar2(title)
%     Create a new status/progress bar. If title is an empty
%     string, the default 'Progress ...' will be used.
%
%  f=statusbar2(title,f)
%     Reset an existing status/progress bar or create a new
%     if the handle became invalid.
%
%  f=statusbar2(topDone,BottomDone,f)
%     For 0 < topDone < 1, 0 < BottomDone < 1 updates the progress bar and the
%     elapsed time. Estimate the remaining time until completion.
%     On user abort, return an empty handle.
%
%   statusbar2(f,'Title');
%       Change the secondary  process' title
%
%  delete(statusbar)
%     Remove all status/progress bars.
%
%  drawnow
%     Refresh all GUI windows.
%
%Example:
%
%                 f=statusbar2('Wait some seconds ...');
%                 for p=1:10
%                     statusbar2(f,'First');
%                         for p2=1:5
%                             pause(0.1);
%                             statusbar2(p/10,p2/5,f);
%                             if isempty(statusbar2)
%                                 return;
%                             end
%                         end; 
%                     statusbar2(f,'Second');
%                     for p2=1:5
%                         pause(0.1);
%                         statusbar2(p/10,p2/5,f);
%                         if isempty(statusbar2)
%                              return;
%                         end
%                     end;
%                 end;
%
%      This file is a modification of Leutenegger Marcel's statusbar 
%      published at matalab's file exchange
%      Author : Tal Pasi
%      Date : 9/10/2004

if nargin < nargout           % get handles
    o='ShowHiddenHandles';
    t=get(0,o);
    set(0,o,'on');
    f=findobj(get(0,'Children'),'flat','Tag','StatusBar');
    set(0,o,t);
    return;
end

if nargin==2 & ishandle(p)
      modify(p,'SeconderyTitle','String', p2);
end
    
if nargin & ischar(p)
    if nargin == 3 & check(f)  % reset
        modify(f,'Line','XData',[4 4 4]);
        modify(f,'Rect','Position',[4 44 0.1 22]);
        modify(f,'Done','String','0');
        modify(f,'Time','String','0:00:00');
        modify(f,'Task','String','0:00:00');
    else
            f=create;               % create 
    end
    if p
        set(f,'Name',p);
    end
    
    set(f,'CloseRequestFcn','set(gcbo,''UserData'',-abs(get(gcbo,''UserData'')));','UserData',[cputime cputime 0 0;cputime cputime  0 0]);
    drawnow;
  
elseif nargin == 3 & check(f) % update
    t=get(f,'UserData');
   
    if isempty(t) || any(t(1,:) < 0)              % confirm
        if p >= 1 | strcmp(questdlg({'Are you sure to stop the execution now?',''},'Abort requested','Stop','Resume','Resume'),'Stop')
            delete(f);
            f=[];                % interrupt
            return;
        end
        t=abs(t);
        set(f,'UserData',t);    % continue
    end
    p=min(1,max([0 p]));
    p2=min(1,max([0 p2]));
    
    % Refresh display if
    %
    %  1. still computing
    %  2. computation just finished
    %    or
    %     more than a second passed since last refresh
    %    or
    %     at least 1% computed since last refresh
    
    % the display for the main progress bar
    if any(t(1,:)) && p~=0 && (p >= 1 || cputime-t(1,2) > 0.5 || p-t(1,4) >= 0.01)
       
        elp =  cputime-t(1,1);  % the elapsed time

        yAvg = elp/(p*100);         % the average time of one precent increment
        
        estm = yAvg*(1-p)*100;      % estimated time remaining  
        
        set(f,'UserData',[t(1,1) cputime t(1,3)  p;t(2,1) t(2,2)  t(2,3) t(2,4)]);
        
        h=floor(elp/60);
        
        modify(f,'TopLine2','XData',[4 4+348*p 4+348*p]);
        modify(f,'TopRect2','Position',[4 124 max(0.1,348*p) 22]);
      
        % change the color of the bar to red when it reaches 95%
        if floor(p*100+0.5) >= 95
            modify(f,'TopRect2','FaceColor','red');
        else
            modify(f,'TopRect2','FaceColor','blue');
        end
        
        modify(f,'TopDone','String',sprintf('%u',floor(p*100+0.5)));    % the precent notifier
        % change the elapsed time text
        modify(f,'TopElapsed','String',sprintf('%u:%02u:%02u',[floor(h/60);mod(h,60);mod(floor(elp),60)]));
        
        % change the remaining time text
        if p > 0.01 | (elp > 60 && p ~=0)
            t=ceil(estm);
            h=floor(t/60);
            modify(f,'TopRemaining','String',sprintf('%u:%02u:%02u',[floor(h/60);mod(h,60);mod(t,60)]));
        end
        % all done
        if p == 1
            set(f,'CloseRequestFcn','delete(gcbo);','UserData',[]);
            return
        end
    end
    
    t=get(f,'UserData');
    % the display for the nested progress bar
    if any(t(2,:)) && (p2 >= 1 || cputime-t(2,2) > 0.5 || p2-t(2,4) >= 0.01)
         
        elp =  cputime-t(2,1);   % the elapsed time
        warning off
        yAvg = elp/(p2*100);    % the average time of one precent increment
        
        estm = yAvg*(1-p2)*100; % estimated time remaining  
        
        if p2==1
            % reset the bar's data to its starting mode
            set(f,'UserData',[t(1,1) cputime t(1,3) p; cputime cputime  0 0]);
        else
            set(f,'UserData',[t(1,1) cputime t(1,3) p; t(2,1) cputime  yAvg p2]);
        end
       
        modify(f,'Line2','XData',[4 4+348*p2 4+348*p2]);
        modify(f,'Rect2','Position',[4 34 max(0.1,348*p2) 22]);

        % change the color of the bar to red when it reaches 95%
        if floor(p2*100) >= 95
            modify(f,'Rect2','FaceColor','red');
        else
            modify(f,'Rect2','FaceColor','blue');
        end
        
        modify(f,'LowDone','String',sprintf('%u',floor(p2*100))); % the precent notifier
        
        % change the remaining time text
        if p2 > 0.05 | (elp > 60 && p2 ~=0)
            t=ceil(estm);
            h=floor(t/60);
            modify(f,'LowRemaining','String',sprintf('%u:%02u:%02u',[floor(h/60);mod(h,60);mod(t,60)]));
        end
        
        drawnow;
        
    end
end

if ~nargout
    clear;
end


%Check if a given handle is a progress bar.
function f=check(f)
if f & ishandle(f(1)) & strcmp(get(f(1),'Tag'),'StatusBar')
    f=f(1);
else
    f=[];
end


%Create the progress bar.
function f=create(currTitle)
s=[356 180];
t=get(0,'ScreenSize');
f=figure('DoubleBuffer','on','HandleVisibility','off','MenuBar','none','Name','Progress ...','IntegerHandle','off','NumberTitle','off','Resize','off','Position',[floor((t(3:4)-s)/2) s],'Tag','StatusBar','ToolBar','none');
a.Parent=axes('Parent',f,'Position',[0 0 1 1],'Visible','off','XLim',[0 356],'YLim',[0 180]);
%
%Horizontal bar
%
rectangle('Position',[4 124 348 22],'EdgeColor','white','FaceColor',[0.7 0.7 0.7],'Tag','TopRect1',a);
line([4 4 352],[125 146 146],'Color',[0.5 0.5 0.5],'Tag','TopLine1',a);
rectangle('Position',[4 124 0.1 22],'EdgeColor','white','FaceColor','red','Tag','TopRect2',a);
line([4 4 4],[124 124 147],'Color',[0.2 0.2 0.2],'Tag','TopLine2',a);

rectangle('Position',[4 34 348 22],'EdgeColor','white','FaceColor',[0.7 0.7 0.7],'Tag','Rect1',a);
line([4 4 352],[35 56 56],'Color',[0.5 0.5 0.5],'Tag','Line1',a);
rectangle('Position',[4 34 0.1 22],'EdgeColor','white','FaceColor','red','Tag','Rect2',a);
line([4 4 4],[34 34 57],'Color',[0.2 0.2 0.2],'Tag','Line2',a);

line([1 1 356],[94 94 94],'Color',[0.2 0.2 0.2],a);
line([1 1 356],[90 90 90],'Color',[0.2 0.2 0.2],a);
rectangle('Position',[1 90 356 2],'EdgeColor','white','FaceColor',[0.7 0.7 0.7],a);
%
%Description texts
%
a.FontWeight='bold';

a.Units='pixels';
a.VerticalAlignment='middle';
text(4,166,'Overall Progress',a);

if exist('currTitle')
   text(4,72,currTitle,a); 
else
    text(4,72,'Current Progress',a,'Tag','SeconderyTitle');
end

a.Color = 'white';
text(176,136,1,'%',a,'Tag','TopPrecent');
text(176,46,1,'%',a,'Tag','LowPrecent');

a.Color = 'black';
a.FontWeight='normal';
text(14,110,'Elapsed time:',a);
text(170,110,'Remaining:',a);
text(170,20,'Remaining:',a);



%
%Information texts
%
a.HorizontalAlignment='right';

text(140,110,'0:00:00',a,'Tag','TopElapsed');
text(280,110,'0:00:00',a,'Tag','TopRemaining');

text(280,20,'0:00:00',a,'Tag','LowRemaining');

a.Color = 'white';
a.FontWeight='bold';
text(176,136,1,'0',a,'Tag','TopDone');
text(176,46,1,'0',a,'Tag','LowDone');




%Modify an object property.
function modify(f,t,p,v)
set(findobj(f,'Tag',t),p,v);



