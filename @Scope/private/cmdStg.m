function [ok,arg]=cmdStg(rS,cmd,param)
% cmdStg send a specific command to the stage
% currnetly implemented using ASI ascii set, should move to MMC in the
% future.
%
% This is a private method for @Scopre, interface with stage should be done
% via the set/get commands
%
% Possible cmd values:
% move,moverel,where,zero,fcsscr,autofocus

% check input:
error(nargchk(2,3,nargin))
% if sum(ismember(cmd,{'move','moverel','where','zero','fcsscr','setFocusSpeed','setFocusRange','autofocus','getStatus'}))~=1
%     error([cmd ' is not a legit command to stage']);
% end
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
            cmdstr=[cmdstr param(i).axis '=' num2str(param(i).position) ' ']; %#ok<AGROW>
        end
        % perform the commnad
        sub_cmdStg(cmdstr);
    case 'where'
        cmdstr=['W ' param];
        % perform the commnad
        sub_cmdStg(cmdstr);
        %return the position
        arg=str2double(cnf(4:end)); 
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
        arg.type=parseASI(cnf{3}); 
        arg.speed_fine=parseASI(cnf{4});
        arg.speed_corase=parseASI(cnf{5});
        arg.range_fine=parseASI(cnf{6});
        arg.range_corase=parseASI(cnf{7});
        arg.hill_offset=parseASI(cnf{10});         

        
    case 'setfocusspeed'
        cmdstr=['AFSET X=' num2str(param)];
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'setfocusrange'
        cmdstr=['AFSET Y=' num2str(param)];
         % perform the commnad
        sub_cmdStg(cmdstr);
    case 'autofocus'
        cmdstr=['AF ' num2str(param)]; 
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

        ok=isempty(strfind(cnf,'N'));

    end % end of nested subfunction

    function prs=parseASI(str)
        [bla,prs]=strtok(str,':');
        prs=regexprep(prs,':','');
        prs=str2double(prs);
    end

end % end of main function