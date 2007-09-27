function arr = str2arr( str )
%STR2ARR transform a postgres numeric array string into a matrix
%   it takes a str that looks like this:
%   str='{{1,2,3},{4,5,6},{7,8,9}}'
% and return a matrix that looks like this: 
% arr= [ 1     2     3
%          4     5     6
%          7     8     9];
%
% NOTE: This function suport up tp 3 dimentions only - more that that and
% its will return an error or worse!
% 
% see also arr2str for the reciprocal tranformation

if length(str) < 3
    arr=[];
    return
end

switch  length(strfind(str(1:3),'{'))
    case 0
        arr=str2double(str); 
    case {1,2}
        str = regexprep(str, '{', '[');
        str = regexprep(str, '},', '];');
        str = regexprep(str, '}', ']');
        arr=eval(str);
    case 3
        % strip the finale ones
        str=str(1:end); 
        ix=strfind(str,'}},{{')+2;
        arr=[];
        ix=[1 ix length(str)];
        for i=2:length(ix)
            arr=cat(3,arr,str2arr(str(ix(i-1)+1:ix(i)-1)));
        end
    otherwise
        error('Only supporting up to 3 dimensional arrays, concatenation will be wrong!');
end
        