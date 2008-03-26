function str = arr2str(arr)
%ARR2STR transforms a 1-3 dimensional array into Postgres array syntax

%%
if isstruct(arr)
    str=struct2xml(arr);
    return
end

if length(size(arr))>3
    error('Can only handle up to 3 dimensionsl arrays');
end

% deal with scalars
if numel(arr)==1
    str=sprintf('%.8f',arr); 
    return
end

%% If input is provided as a cell array, loop around all cells and convert
% each one seperatrly, returning a cell array of the same size

if iscell(arr)
    str=cell(size(arr));
    for i=1:numel(att)
        str{i}=arr2str(arr{i});
    end
    return
end


%%
[r,c,dz]=size(arr);
str_1d=cell(r,dz);

for i=1:dz
    for j=1:r
        for k=1:c
            if k>1
                sub_str=sprintf('%s,%.8f',sub_str,arr(j,k,i));
            else
                sub_str=sprintf('{%.8f',arr(j,k,i));
            end
        end
        sub_str=[sub_str '}'];
        str_1d{j,i}=sub_str;
    end
end

% deal with the sigle row case
if numel(str_1d)==1
    str=str_1d{1}; 
    return
end

str_2d=cell(dz,1);
% if there are more than one row
for j=1:dz
    for i=1:r
        if i==1
            str_2d{j}=['{' str_1d{i,j}];
        else
            str_2d{j}=[str_2d{j} ',' str_1d{i,j}];
        end
    end
    str_2d{j}=[str_2d{j} '}'];

end

if dz>1
    for i=1:dz
        if i==1
            str=['{' str_2d{i}];
        else
            str=[str ',' str_2d{i}];
        end
    end
    str=[str '}'];
else
    str=str_2d{1};
end

%% add '' around NaNs
str=regexprep(str,'NaN','''NaN''');

    