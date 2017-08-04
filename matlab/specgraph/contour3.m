function [cout, h, msg] = contour3(varargin)
    %CONTOUR3 3-D contour plot.
    %   CONTOUR3(...) is the same as CONTOUR(...) except that:
    %      * the contours are drawn at their corresponding Z level
    %      * multiple patch objects are created instead of a contourgroup
    %      * CONTOUR3 does not accept property-value pairs. Use SET instead
    %        on the patch handles.
    %
    %   C = CONTOUR3(...) returns contour matrix C as described in CONTOURC
    %   and used by CLABEL.
    %
    %   [C, H] = CONTOUR3(...) returns a column vector H of handles to PATCH
    %   objects. The UserData property of each object contains the height
    %   value for each contour.
    %
    %   Example:
    %      contour3(peaks);
    %
    %   See also CONTOUR, CONTOURF, CLABEL, COLORBAR.
    
    %   Additional details:
    %
    %   Unless a linestyle is specified, CONTOUR3 will draw PATCH objects
    %   with edge color taken from the current colormap.  When a linestyle
    %   is specified, LINE objects are drawn.  To produce the same results
    %   as v4, use CONTOUR3(..., '-').
    %
    %   The order of the handles h relative to the values in cout is used
    %   in CLABEL to create rotated inline labels.  If you change this
    %   order, you may have to change CLABEL also.
    
    %   Clay M. Thompson 3-20-91, 8-18-95
    %   Modified 1-17-92, LS
    %   Copyright 1984-2011 The MathWorks, Inc.
    
    % Determine the number of outputs
    nout = nargout;
    
    % First we check which HG plotting API should be used.
    if ishg2parent( varargin{:} )
        [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
        if (nout == 3)
            warning(message('MATLAB:contour3:EmptyErrorOutputArgument', upper( mfilename )));
        end
        try
            if nout == 0
                contour3HGUsingMATLABClasses(cax, args{:});
            elseif nout == 1
                cout = contour3HGUsingMATLABClasses(cax, args{:});
            else % nout == 2 || nout == 3
                [cout, h] = contour3HGUsingMATLABClasses(cax, args{:});
            end
        catch me
            throw(me)
        end
        msg = [];
    else
        [~, args] = usev6plotapi(varargin{:});
        [cax, args] = axescheck(args{:});
        if (nout == 3)
            warning(message('MATLAB:contour3:DeprecatedErrorOutputArgument', upper( mfilename )));
        end
        % Parse possible Axes input
        nargs = length(args);
        error(nargchk(1, 6, nargs, 'struct'));
        
        % Create the plot
        cax = newplot(cax);
        
        % Check for empty arguments.
        for i = 1 : nargs
            if isempty(args{i})
                error(message('MATLAB:contour3:EmptyInput'));
            end
        end
        
        % Trim off the last arg if it's a string (line_spec).
        nin = nargs;
        if ischar(args{end})
            [lin, col, ~, msg] = colstyle(args{end});
            if ~isempty(msg)
                error(msg);
            end
            nin = nin - 1;
        else
            lin = '';
            col = '';
        end
        
        if nin <= 2
            [mc, nc] = size(args{1});
            lims = [1, nc, 1, mc];
        else
            lims = [min(args{1}(:)), max(args{1}(:)), ...
                min(args{2}(:)), max(args{2}(:))];
        end
        
        if isempty(col) % no color spec was given
            colortab = get(cax, 'ColorOrder');
            mc = size(colortab, 1);
        end
        
        % Check for level or number of levels N.  If it's a scalar and a
        % non-zero integer, we assume that it must be N.  Otherwise we
        % duplicate it so it's treated as a contour level.
        if nin == 2 || nin == 4
            if numel(args{2}) == 1 % might be N or a contour level
                if ~(args{2} == fix(args{2}) && args{2})
                    args{2} = [args{2}, args{2}];
                end
            end
        end
        
        % Suppress the warning about the deprecated contours error output.
        oldWarn(1) = warning('off', 'MATLAB:contours:DeprecatedErrorOutputArgument');
        oldWarn(2) = warning('off', 'MATLAB:contours:EmptyErrorOutputArgument');
        try
            % Use contours to get the contour levels.
            [c, msg] = contours(args{1 : nin});
        catch err
            warning(oldWarn);
            rethrow(err);
        end
        warning(oldWarn);
        
        if ~isempty(msg)
            if nout == 3
                cout = [];
                h = [];
                return
            else
                error(msg);
            end
        end
        
        if isempty(c)
            h = [];
            if nout > 0
                cout = c;
            end
            return
        end
        
        if ~ishold(cax)
            view(cax, 3);
            grid(cax, 'on');
            set(cax, 'XLim', lims(1 : 2), 'YLim', lims(3 : 4));
        end
        
        limit = size(c, 2);
        i = 1;
        h = [];
        color_h = [];
        while (i < limit)
            z_level = c(1, i);
            npoints = c(2, i);
            nexti = i + npoints + 1;
            
            xdata = c(1, i + 1 : i + npoints);
            ydata = c(2, i + 1 : i + npoints);
            zdata = z_level + 0 * xdata;  % Make zdata the same size as xdata
            
            % Create the patches or lines
            if isempty(col) && isempty(lin)
                cu = patch('XData', [xdata, NaN], 'YData', [ydata, NaN], ...
                    'ZData', [zdata, NaN], 'CData', [zdata, NaN], ...
                    'FaceColor', 'none', 'EdgeColor', 'flat', ...
                    'UserData', z_level, 'Parent', cax);
            else
                cu = line('XData', xdata, 'YData', ydata, 'ZData', zdata, ...
                    'UserData', z_level, 'Parent', cax);
            end
            h = [h; cu(:)]; %#ok<AGROW>
            color_h = [color_h; z_level]; %#ok<AGROW>
            i = nexti;
        end
        
        % Register handles with m-code generator
        if ~isempty(h)
            mcoderegister('Handles', h, 'Target', h(1), 'Name', 'contour3');
        end
        
        if isempty(col) && ~isempty(lin)
            % set linecolors - all LEVEL lines should be same color
            % first find number of unique contour levels
            [zlev, ind] = sort(color_h);
            h = h(ind);     % handles are now sorted by level
            ncon = length(find(diff(zlev))) + 1;    % number of unique levels
            if ncon > mc    % more contour levels than colors, so cycle colors
                % build list of colors with cycling
                ncomp = round(ncon / mc); % number of complete cycles
                remains = ncon - ncomp * mc;
                one_cycle = (1 : mc)';
                index = one_cycle(:, ones(1, ncomp));
                index = [index(:); (1 : remains)'];
                colortab = colortab(index, :);
            end
            j = 1;
            zl = min(zlev);
            for i = 1 : length(h)
                if zl < zlev(i)
                    j = j + 1;
                    zl = zlev(i);
                end
                set(h(i), 'LineStyle', lin, 'Color', colortab(j, :));
            end
        else
            if ~isempty(lin)
                set(h, 'LineStyle', lin);
            end
            if ~isempty(col)
                set(h, 'Color', col);
            end
        end
        
        % If command was of the form 'c = contour(...)', return the results
        % of the contours command.
        if nout > 0
            cout = c;
        end
    end
end

