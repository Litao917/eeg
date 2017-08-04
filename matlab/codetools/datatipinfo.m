function datatipinfo(val)
    %DATATIPINFO Produce short description of input variable
    %   DATATIPINFO(X) produces a short description of a variable, as for
    %   use in debugger DataTips.
    
    %   Copyright 1984-2012 The MathWorks, Inc.
    if nargin ~= 1
        return
    end
    
    origFormat = get(0,'FormatSpacing');
    c = onCleanup(@()format(origFormat));
    format loose;
    
    name = inputname(1);
    if isstruct(val)
        % disp the result of display, without the equal sign and
        % with the correct variable name.
        displayStr = evalcWithHotlinksOff('display(val)');
        pat = '\s*val\s*=\s*([^\n]*)\n+';
        rep = [name, ': $1\n'];
        if isscalar(val) && numel(fieldnames(val)) > 0
            pat = '\s*val\s*=\s*\n+';
            rep = [name, ':\n'];
        end
        disp(regexprep(displayStr, pat, rep, 'once'));
    elseif isempty(val)
        callDisp('sizeType');
    else
        % The short description amounts to a summary, so we don't want
        % to produce a huge amount of information.  As a rough rule of
        % thumb, print the full text of the value only if the total
        % number of elements is less than an arbitrary cutoff (500).
        % Note that the size of a variable can be large while numel
        % still returns something small (for example, a dataset).
        s = size(val);
        tooBig = max(s) > 500 || numel(val) > 500;
        if ~ismatrix(val) || tooBig && s(1) ~= 1 && s(2) ~= 1
            % val is too big, and not a row or a column, just print a
            % description of the value (along the lines of '40x40 double')
            callDisp('sizeType');
        else
            callDisp('[sizeType '' ='']');
            
            if ~isobject(val) && ~issparse(val) && tooBig
                % val is too big, but it is a row or a column matrix, so 
                % just print the first 500 elements
                val = val(1:500);
            end
            
            if ischar(val) && s(1) == 1
                % val is a string, preprocess the special characters that the
                % datatip can't handle, but the command window does.
                while ~isempty(regexp(val, '[^\b]\b', 'once'))
                    % remove backspaces and the character prior to them
                    val = regexprep(val, '[^\b]\b', '');
                end
                % make carriage retures look like newlines
                val = regexprep(val, '\r', '\n');
            end
            
            callDisp('val');
        end
    end
    
    function prefix=sizeType %#ok<DEFNU> All uses are in EVALC calls.
        s = size(val);
        D = numel(s);
        if D == 2
            theSize = [num2str(s(1)), 'x', num2str(s(2))];
        elseif D == 3
            theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
                num2str(s(3))];
        else
            theSize = [num2str(D) '-D'];
        end
        if isempty(val) == 0
            prefix = [name ': ' theSize ' ' class(val)];
        else
            prefix = [name ': empty ' theSize ' ' class(val)];
        end
    end
    
    function varargout = evalcWithHotlinksOff(cmdStr)
        evalStr = ['feature(''hotlinks'', 0); ', cmdStr];
        varargout{1:nargout} = evalc(evalStr);
    end

    function callDisp(stringArg)
        evalStr = ['disp(', stringArg, ')'];
        disp(evalcWithHotlinksOff(evalStr));
    end
end
