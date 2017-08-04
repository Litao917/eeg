function [cnts,headings] = summary(a,dim)
%SUMMARY Print summary of a categorical array.
%   SUMMARY(A) displays the number of elements in the categorical array A
%   that are equal to each of A's categories.  If A contains any undefined
%   elements, the output also includes the number of undefined elements.
%
%   If A is a vector, SUMMARY displays counts for the entire vector.  If A is a
%   matrix or N-D array, SUMMARY displays counts separately for each column of A.
%
%   SUMMARY(A,DIM) displays the summary computed along the dimension DIM of A.
%
%   See also ISCATEGORY, ISMEMBER, COUNTCATS.

%   Copyright 2006-2013 The MathWorks, Inc. 

if nargin==1
    dim = find(size(a)~=1,1,'first');
    if isempty(dim), dim = 1; end
end
c = countcats(a,dim);
catnames = a.categoryNames;
nundefs = sum(isundefined(a),dim);
if any(nundefs(:) > 0)
    c = cat(dim,c,nundefs);
    if nargout ~= 1
        catnames = [catnames;categorical.undefLabel];
    end
end
headings = permute(catnames,circshift(1:max(dim,2),[0 dim-1]));

if nargout < 1
    % Add row headers for column summaries and column headers for row summaries.
    if dim < 3
        if ~ismatrix(c)
            tile = size(c); tile(1:2) = 1;
            headings = repmat(headings,tile);
        end
        c = cat(3-dim,headings,num2cell(c));
    end

    str = evalc('disp(c)');

    % Do some regexp magic to put the category names into summaries along higher dims.
    if dim > 2
        for i = 1:length(headings)
            pattern = ['(\(\:\,\:' repmat('\,[0-9]',[1,dim-3]) '\,)' ...
                       '(' num2str(i) ')' ...
                       '(' repmat('\,[0-9]',[1,ndims(c)-dim]) '\) *= *\n)'];
            rep = ['$1' headings{i} '$3'];
            str = regexprep(str,pattern,rep);
        end
    end

    str = str(1:end-1); % remove trailing newline
    % Find brackets containing numbers in any format, and preceded by
    % whitespace -- those are the counts.  Replace those enclosing brackets
    % with spaces.  Then replace quotes around category names with spaces.
    str = regexprep(str,'(\s)\[([^\]]+)\]','$1 $2 ');
    catnamesList = ['(' strjoin(fliplr(sort(catnames')),'|') ')']; %#ok<TRSRT,FLPST>
    str = regexprep(str,['\<\''' catnamesList '\''\>'],' $1 ');

    % Wrap tags around headings to make the category names bold. Have to do this
    % after capturing the output because the tags would mess up alignment for
    % column headings in cell display, and make almost any heading too long for
    % cell to display.
    if feature('hotlinks')
        embolden = @(s) sprintf('<strong>%s</strong>',s); %#ok<NASGU>
        if dim == 1
            str = regexprep(str,['(?<=(^|\n)\s*)' catnamesList],'${embolden($0)}');
        elseif dim == 2
            strs = strsplit(str,'\n');
            if ismatrix(a)
                strs{1} = regexprep(strs{1},catnamesList,'${embolden($0)}');
            else
                isLoose = strcmp(get(0,'FormatSpacing'),'loose');
                for i = (2+isLoose):(size(a,1)+2):length(strs)
                    strs{i} = regexprep(strs{i},catnamesList,'${embolden($0)}');
                end
            end
            str = strjoin(strs,'\n');
        else % dim > 2
            before = ['(?<=\(\:\,\:\,' repmat('\d?\,',1,dim-3) ')'];
            str = regexprep(str,[before catnamesList],'${embolden($0)}');
        end
    end

    disp(str);

elseif isa(a,'nominal') || isa(a,'ordinal')
    cnts = c;
else
    error(message('MATLAB:TooManyOutputs'));
end
