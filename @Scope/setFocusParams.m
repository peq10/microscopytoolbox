function setFocusParams(rSin,argin,param)
%GETFOCUSPARAMS a private method that isolates the call for focus related
%properties. 

% this trick make sure rS is updated without ading it to the output arguments. 
% notice that rSin MUST be the same global rS object. 
global rS;
rS = rSin;

switch lower(argin)
    case 'focusrange'
        cmdstr=['AFSET Y=' num2str(param*10)]; % param should be in micron
        rS.mmc.setSerialPortCommand(rS.COM,cmdstr,char(13));
    case 'focusspeed'
        cmdstr=['AFSET X=' num2str(param)]; % param should be in micron
        rS.mmc.setSerialPortCommand(rS.COM,cmdstr,char(13));
%     case 'focushilldetectheight'
%         cmdStg(rS,'setfocushillheight',param);
%     case 'focussearchdirection'
%         switch param
%             case 'UP'
%                 fcstype=2;
%             case 'DOWN'
%                 fcstype=4;
%             case 'SPLIT'
%                 fcstype=6;
%         end
%         if get(rS,'focususehilldetect')
%                 fcstype=fcstype+6;
%         end
%         crntrng=get(rS,'focusrange');
%         set(rS,'focusrange',0);
%         cmdStg(rS,'autofocus',fcstype);
%         set(rS,'focusrange',crntrng);
%     case 'focususehilldetect'
%         if (crntfcsparams.type<=6) && param
%             fcstype=crntfcsparams.type+6;
%             crntrng=get(rS,'focusrange');
%             set(rS,'focusrange',0);
%             cmdStg(rS,'autofocus',fcstype);
%             set(rS,'focusrange',crntrng);
%         elseif (rS.focusParams.type>6) && ~param
%             fcstype=rS.focusParams.type-6;
%             crntrng=get(rS,'focusrange');
%             set(rS,'focusrange',0);
%             cmdStg(rS,'autofocus',fcstype);
%             set(rS,'focusrange',crntrng);
%         end
    otherwise
        warning('Focus Property does not exist or cannot be chagned'); %#ok
end

rS.focusParams=[];

