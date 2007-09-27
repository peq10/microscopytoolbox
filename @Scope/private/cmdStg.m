function [ok,arg]=cmdStg(rS,cmd,param)
% cmdStg send a specific command to the stage
% currnetly implemented using ASI ascii set, should move to MMC in the
% future.
%
% This is a private method for @Scope, interface with stage should be done
% via the set/get commands
%
% For Possible cmd values see Developer Guide
% 
% Note, all units are in microns, if ASI doesn't use microns, I corrent
% accordingly.

% check input:
error(nargchk(2,3,nargin))

lastwarn('')
ok=0;
cnf='';
arg=cnf;

switch lower(cmd)
    case 'zero'
        cmdstr=['Z ' param];
        % perform the commnad
        sub_cmdStg(cmdstr);
        %return the success value
        arg=ok; 
    case 'getfocusparam'
        cmdstr='AF X?';
        % perform the commnad
        sub_cmdStg(cmdstr,10);
        
        % parse the status
        for jj=1:length(cnf)
            fld=strtok(cnf{jj},':');
            switch fld(2:end)
                case 'current_type'
                    arg.type=parseASI(cnf{jj});
                case 'X=fine_speed'
                    arg.speed_fine=parseASI(cnf{jj});
                case 'X=coarse_speed'
                    arg.speed_corase=parseASI(cnf{jj});
                case 'Y=travel fine'
                    arg.range_fine=parseASI(cnf{jj})*1000;
                case 'Y=travel coarse'
                    arg.range_corase=parseASI(cnf{jj})*1000;
                case 'F=hill_offset'
                    arg.hill_offset=parseASI(cnf{jj});
            end
        end
    case 'setfocusspeed'
        cmdstr=['AFSET X=' num2str(param)];
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'setfocusrange'
        cmdstr=['AFSET Y=' num2str(param*10)];
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'setfocushillheight'
        cmdstr=['AFSET F=' num2str(param)];
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'autofocus'
        if exist('param','var')
            cmdstr=['AF X=' num2str(param)];
        else
            cmdstr='AF';
        end
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'getstatus'
        cmdstr='/';
        % perform the commnad
        sub_cmdStg(cmdstr);
        % update the arg output
        if ~isempty(findstr(cnf,'B'))
            arg=1;
        else %cnf should include N
            arg=0;
        end
    case 'getspeed'
        cmdstr=['S ' param '?'];
        sub_cmdStg(cmdstr);
        arg=str2double(cnf(7:end))*1000;
    case 'setspeed'
        cmdstr=['S ' param.axis '=' num2str(param.speed)];
        sub_cmdStg(cmdstr);
    otherwise
        error([cmd ' is not a valid command for the sate']);
end

%% perform the command


% nested subfunction
    function sub_cmdStg(cmdstr,n)
        cnf={};
        % n if the number of expected line in output. 
        if nargin==1
            n=1;
            
        end
        rS.mmc.setSerialPortCommand(rS.COM,cmdstr,char(13));
        
        for ii=1:n
            
            cnf{ii}=char(rS.mmc.getSerialPortAnswer(rS.COM,char(13))); %#ok
        end
        
        if n==1
            cnf=cnf{1}; 
        end

%         % try again in case of timeout (good for autofocusing or something like that)
%         if ~isempty(lastwarn)
%             cnf=fscanf(rS.Stg);
%             disp('repeating fscanf');
%         end
        
        if ~iscell(cnf)
            ok=isempty(strfind(cnf,'N'));
        else
            ok=1;
        end

    end % end of nested sub_cmdStg subfunction

    function prs=parseASI(str)
        [bla,prs]=strtok(str,':');
        prs=regexprep(prs,':','');
        prs=str2double(prs);
    end % end of praseASI

end % end of main function