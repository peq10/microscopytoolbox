function [ok,arg]=cmdStg(rS,cmd,param)
% cmdStg send a specific command to the stage
% currnetly implemented using ASI ascii set, should move to MMC in the
% future.
%
% This is a private method for @Scope, interface with stage should be done
% via the set/get commands
%
% For Possible cmd values see DEveloper Guide
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
    case {'move','moverel'} % deal with both cases at once
        switch cmd
            case 'move'
                cmdstr='M ';
            case 'moverel'
                cmdstr='R ';
        end
        for i=1:length(param)
            cmdstr=[cmdstr param(i).axis '=' num2str(param(i).position*10) ' ']; %#ok<AGROW>
        end
        % perform the commnad
        sub_cmdStg(cmdstr);
    case 'where'
        cmdstr=['W ' param];
        % perform the commnad
        sub_cmdStg(cmdstr);
        %return the position
        arg=str2double(cnf(4:end))/10; 
    case 'zero'
        cmdstr=['Z ' param];
        % perform the commnad
        sub_cmdStg(cmdstr);
        %return the success value
        arg=ok; 
    case 'fcsscr'
        cmdstr='rdadc z';
        % perform the commnad
        sub_cmdStg(cmdstr);
        %return the position
        arg=str2double(cnf(4:end)); 
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
                    arg.range_corase=parseASI(cnf{jj});
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
            cmdstr=['AF ' num2str(param)];
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
        if strcmp(cnf,'B')
            arg=1;
        else %cnf should be N
            arg=0;
        end
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
        fprintf(rS.Stg,cmdstr);
        
        for ii=1:n
            
            cnf{ii}=fgetl(rS.Stg); %#ok
        end
        
        if n==1
            cnf=cnf{1}; 
        end

        % try again in case of timeout (good for autofocusing or something like that)
        if ~isempty(lastwarn)
            cnf=fscanf(rS.Stg);
            disp('repeating fscanf');
        end
        
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