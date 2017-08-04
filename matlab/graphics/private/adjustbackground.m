function adjustbackground( state, fig )
%ADJUSTBACKGROUND Modify figure to save printer toner.
%   This undocumented helper function is for internal use.

%   ADJUSTBACKGROUND(STATE,FIG) modifies the color of graphics objects to
%   print them on a white background (thus saving printer toner).  STATE is
%   either 'save' to set up colors for a white background or 'restore'. If
%   the Color property of FIG is 'none', nothing is done.
%
%   ADJUSTBACKGROUND(STATE) operates on the current figure.
%
%   See also CONTRASTCOLORS, PRINT.

%   When printing your Figure window, it is not usually desirable to draw
%   using the background color of the Figure and Axes. Dark backgrounds
%   look good on screen but tend to over-saturate the output page.
%   ADJUSTBACKGROUND will Change the Color, MarkerFaceColor,
%   MarkerEdgeColor, FaceColor, and EdgeColor property values of all
%   objects and the X, Y, and Z Colors of all Axes to black if the Figure
%   and Axes are not already white. ADJUSTBACKGROUND will also restore the
%   original colors of the objects with the correct input argument.

%   Copyright 1984-2013 The MathWorks, Inc.

persistent SaveTonerOriginalColors;

if nargin == 0 ...
        || ~ischar( state ) ...
        || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
    error(message('MATLAB:adjustbackground:NeedsMoreInfo'))
elseif nargin ==1
    fig = gcf;
end

NONE = [NaN NaN 0];
FLAT = [NaN 0 NaN];
BLACK = [0 0 0];
WHITE = [1 1 1];

usingMATLABClasses = ~useOriginalHGPrinting(fig); 
if usingMATLABClasses
    findobjFcn = @findobjinternal;
else
    findobjFcn = @findobj;
end

if strcmp( state, 'save' )

    % need to remember if using MATLAB classes
    storage.HGUsingMATLABClasses = usingMATLABClasses;

    origFigColor = get(fig,'color');
    saveOrigFigColor = get(fig,'color');

    if isequal( get(fig,'color'), 'none')
        saveOrigFigColor = [NaN NaN NaN];
    end

    origFigWhite = 0;
    if isequal(WHITE, saveOrigFigColor)
        origFigWhite = 1;
    end

    %Initialize all counts
    count.color = 0;
    count.facecolor = 0;
    count.edgecolor = 0;
    count.markeredgecolor = 0;
    count.markerfacecolor = 0;

    allAxes = findobjFcn(fig,'type','axes','-or','type','legend','-or','type','colorbar');
    
    % Remove any axes objects which don't have a Color property (like
    % ColorBar, for example), since there is nothing to do for these
    % objects anyway.
    for axnum = length(allAxes):-1:1
        if ~isprop(allAxes(axnum), 'Color');
            allAxes(axnum) = [];
        end
    end
    
    naxes = length(allAxes);
    for axnum = 1:naxes
        a = allAxes(axnum);
        origAxesColor = get(a,'color');
        chil = allchild(a);
        axesVisible = strcmp(get(a,'visible'), 'on');

        % Exclude Axes labels from child because they are handled as a special
        % case below since they lie outside of the axes.
        if ~isempty(chil) 
           excludedH = get(a, {'xlabel';'ylabel';'zlabel';'title'});
           excludedH = cat(1, excludedH{:})'; % turn cell array into row vector
           for hLabel = excludedH
               chil(double(chil) == double(hLabel)) = []; % remove excluded handles
           end
        end

        %Early exit criteria
        if isempty(chil) || (axesVisible && isequal(origAxesColor,WHITE)) ...
                || ((~axesVisible || strcmp(origAxesColor,'none')) && origFigWhite)

            % Do nothing
        else
            %Objects properties that are W will goto K to stay contrasting and those
            %  that match the ultimate background color goto W to stay invisible.
            if ~axesVisible || strcmp(origAxesColor,'none')
                bkgrndColor = origFigColor;
            else
                bkgrndColor = origAxesColor;
            end

            count.color = count.color + length(findobjFcn(chil,'color',WHITE,'Visible','on'));
            count.facecolor = count.facecolor + length(findobjFcn(chil,'facecolor',WHITE,'Visible','on'));
            count.edgecolor = count.edgecolor + length(findobjFcn(chil,'edgecolor', WHITE,'Visible','on'));
            count.markeredgecolor = count.markeredgecolor + length(findobjFcn(chil,'markeredgecolor',WHITE,'Visible','on'));
            count.markerfacecolor = count.markerfacecolor + length(findobjFcn(chil,'markerfacecolor',WHITE,'Visible','on'));

            count.color = count.color + length(findobjFcn(chil,'color', bkgrndColor,'Visible','on'));
            count.facecolor = count.facecolor + length(findobjFcn(chil,'facecolor', bkgrndColor,'Visible','on'));
            count.edgecolor = count.edgecolor + length(findobjFcn(chil,'edgecolor', bkgrndColor,'Visible','on'));
            count.markeredgecolor = count.markeredgecolor + length(findobjFcn(chil,'markeredgecolor', bkgrndColor,'Visible','on'));
            count.markerfacecolor = count.markerfacecolor + length(findobjFcn(chil,'markerfacecolor', bkgrndColor,'Visible','on'));
        end

        %Handle special case
        %The Axes labels and title are outside the bounds of the
        %Axes and therefore contrastness needs to be checked with
        %the Figure.
        if ~origFigWhite && isprop(a, 'XLabel') && isprop(a, 'YLabel') ...
                && isprop(a, 'ZLabel') && isprop(a, 'Title')
            %Determine the number of labels which are white so that they
            %can be changed to black before printing
            count.color = count.color + length( findobjFcn( ...
                [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], ...
                '-depth', 0, 'color', WHITE ,'Visible','on')' );
            %Determine the number of labels which are the same color as the figure window
            %so that they can be changed to white before printing
            count.color = count.color + length( findobjFcn( ...
                [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], ...
                '-depth', 0, 'color', origFigColor ,'Visible','on')' );
        end

    end
    
    %Initialize counts based on color we now know we have to change
    % 1st entry is the figure, followed by color matrix
    storage.figure = {fig saveOrigFigColor};

    % one entry for each axes
    %   1st element for the object
    %   next 12 for various colors
    storage.axes = repmat({[] zeros(1,12)}, naxes, 1);

    % various other objects need to have their colors adjusted
    %   1st element for the object
    %   2nd holds color data
    storage.color = repmat({[] zeros(1,3)}, count.color, 1);
    storage.facecolor = repmat({[] zeros(1,3)}, count.facecolor, 1);
    storage.edgecolor = repmat({[] zeros(1,3)}, count.edgecolor, 1);
    storage.markeredgecolor = repmat({[] zeros(1,3)}, count.markeredgecolor, 1);
    storage.markerfacecolor = repmat({[] zeros(1,3)}, count.markerfacecolor, 1);

    % the turnMe structure will hold the info on what we want to change the
    % colors to
    turnMe.color = repmat({[] zeros(1,3)}, count.color, 1);
    turnMe.facecolor = repmat({[] zeros(1,3)}, count.facecolor, 1);
    turnMe.edgecolor = repmat({[] zeros(1,3)}, count.edgecolor, 1);
    turnMe.markeredgecolor = repmat({[] zeros(1,3)}, count.markeredgecolor, 1);
    turnMe.markerfacecolor = repmat({[] zeros(1,3)}, count.markerfacecolor, 1);

    % keep track of the "next" entry in the various arrays to use
    idx.color = 1;
    idx.facecolor = 1;
    idx.edgecolor = 1;
    idx.markeredgecolor = 1;
    idx.markerfacecolor = 1;

    for axnum = 1:naxes
        a = allAxes(axnum);
        chil = allchild(a);

        % Exclude Axes labels from child because they are handled as a special
        % case below since they lie outside of the axes.
        if ~isempty(chil) 
           excludedH = get(a, {'xlabel';'ylabel';'zlabel';'title'});
           excludedH = cat(1, excludedH{:})'; % turn cell array into row vector
           for hLabel = excludedH
               chil(double(chil) == double(hLabel)) = []; % remove excluded handles
           end
        end

        axesVisible = strcmp(get(a,'visible'), 'on');
        origAxesColor = get(a,'color');
        if isprop(a, 'XColor') && isprop(a, 'YColor') && isprop(a, 'ZColor')
            axc = get(a,'xcolor');
            ayc = get(a,'ycolor');
            azc = get(a,'zcolor');
        elseif isprop(a, 'EdgeColor') && isprop(a, 'TextColor')
            % This may be a legend or another object which doesn't have
            % X/Y/Z Colors.  Save the Edge & Text colors instead.
            axc = get(a, 'Color');
            ayc = get(a, 'EdgeColor');
            azc = get(a, 'TextColor');
        end

        aXYZc = [axc ayc azc];
        if ~axesVisible || strcmp(origAxesColor,'none')
            bkgrndColor = origFigColor;
        else
            bkgrndColor = origAxesColor;
        end

        storage.axes(axnum,:) = {a [color2matrix(origAxesColor) aXYZc]};

        %Early exit criteria
        if (axesVisible && isequal(origAxesColor,WHITE)) ...
                || ((~axesVisible || strcmp(origAxesColor,'none')) && origFigWhite)

            % Do nothing
        else
            %Objects properties that are W will goto K to stay contrasting and those
            %  that match the ultimate background color goto W to stay invisible.

            if (~strcmp(origAxesColor, 'none'))
                setGraphicsProperty(a, 'color', WHITE, ...
                    storage.HGUsingMATLABClasses)                
            end

            for obj = findobjFcn(chil,'color',WHITE,'Visible','on')'
                storage.color(idx.color,:) = {obj WHITE};
                turnMe.color(idx.color,:) = {obj BLACK};
                idx.color = idx.color + 1;
            end            

            for obj = findobjFcn(chil,'color', bkgrndColor,'Visible','on')'
                storage.color(idx.color,:) = {obj bkgrndColor};
                turnMe.color(idx.color,:) = {obj WHITE};
                idx.color = idx.color + 1;
            end

            %Face and Edge colors need to be considered together
            for obj = [findobjFcn(chil,'type','surface','Visible','on') ; ...
                    findobjFcn(chil,'type','patch','Visible','on') ; ...
                    findobjFcn(chil,'type','rectangle','Visible','on')]';
                fc =  get(obj,'facecolor');
                ec =  get(obj,'edgecolor');
                if isequal( fc, bkgrndColor )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, WHITE, WHITE, storage, turnMe, idx );
                    else                               [storage, turnMe, idx] = setfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    end

                elseif isequal( fc, WHITE )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, BLACK, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'none' ),      [storage, turnMe, idx] = setfaceedge( obj, BLACK, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end

                elseif isequal( fc, BLACK )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'flat' ),      [storage, turnMe, idx] = setfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    end

                elseif isequal( fc, 'none' )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end

                else %Face is 'flat' or RGB triplet
                    if isequal( ec, WHITE ) || isequal( ec, bkgrndColor )
                        [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end

                end
            end %face and edgecolor loop

            %Marker Face and Edge colors also need to be considered together
            for obj = [ findobjFcn(chil,'type','line','Visible','on') ; ...
                    findobjFcn(chil,'type','surface','Visible','on') ; ...
                    findobjFcn(chil,'type','patch','Visible','on') ]'
                fc =  get(obj,'markerfacecolor');
                ec =  get(obj,'markeredgecolor');
                if isequal( fc, bkgrndColor )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, WHITE, WHITE, storage, turnMe, idx );
                    else                               [storage, turnMe, idx] = setmfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    end

                elseif isequal( fc, WHITE )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, BLACK, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'none' ),      [storage, turnMe, idx] = setmfaceedge( obj, BLACK, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end

                elseif isequal( fc, BLACK )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    end

                elseif isequal( fc, 'none' )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end

                else %Face is RGB triplet
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end

                end
            end %marker face and edge color loop
        end

        %Handle special case #2
        %The Axes labels and title are outside the bounds of the
        %Axes and therefore contrastness needs to be checked with
        %the Figure.
        if ~origFigWhite && isprop(a, 'XLabel') && isprop(a, 'YLabel') ...
                && isprop(a, 'ZLabel') && isprop(a, 'Title')
            %The labels that are white need to be set to black before printing.
            %After printing they need to be set back to their original color, white.
            for obj = findobjFcn( [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], '-depth', 0, 'color', WHITE ,'Visible','on')'
                storage.color(idx.color,:) = {obj WHITE};
                turnMe.color(idx.color,:) = {obj BLACK};
                idx.color = idx.color + 1;
            end

            %The labels that are the same color as the Figure Window need to be
            %set to white before printing.  These labels don't appear on screen
            %and should not appear on the printout.
            for obj = findobjFcn( [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], '-depth', 0, 'color', origFigColor ,'Visible','on')'
                storage.color(idx.color,:) = {obj origFigColor};
                turnMe.color(idx.color,:) = {obj WHITE};
                idx.color = idx.color + 1;
            end
        end

    end %for each Axes

    %Sets the axes labels color for printing
    for k = 1:count.color
        if isprop(turnMe.color{k,1}, 'Type') && ...
                ~strcmp('light', get(turnMe.color{k,1}, 'type'))
            setGraphicsProperty(turnMe.color{k,1}, 'color', ...
                turnMe.color{k,2,:}, storage.HGUsingMATLABClasses);
        end
    end

    % Adjust the axes object's XColor, YColor, and ZColor
    % When setting axis color, make sure label isn't affected.
    % This needs to occur after the label colors are set otherwise in
    % some cases the axis color will reset the label color incorrectly.

    % A FOR loop is necessary so that all WHITEBG subplots are updated
    % correctly.

    for axnum = 1:naxes
        a = allAxes(axnum);
        if isprop(a, 'XColor') && isprop(a, 'YColor') && ...
                isprop(a, 'ZColor') && isprop(a, 'XLabel') && ...
                isprop(a, 'YLabel') && isprop(a, 'ZLabel')
            axc = get(a,'xcolor');
            ayc = get(a,'ycolor');
            azc = get(a,'zcolor');
            
            labelH = get(a,'xlabel');
            labelColor = get(labelH,'color');
            if (isequal(axc,origFigColor))
                setGraphicsProperty(a, 'xcolor', WHITE, ...
                    storage.HGUsingMATLABClasses)
            elseif (isequal(axc,WHITE))
                setGraphicsProperty(a, 'xcolor', BLACK, ...
                    storage.HGUsingMATLABClasses)
            end
            setGraphicsProperty(labelH, 'color', labelColor, ...
                storage.HGUsingMATLABClasses)
            
            labelH = get(a,'ylabel');
            labelColor = get(labelH,'color');
            if (isequal(ayc,origFigColor))
                setGraphicsProperty(a, 'ycolor' ,WHITE, ...
                    storage.HGUsingMATLABClasses)
            elseif (isequal(ayc,WHITE))
                setGraphicsProperty(a, 'ycolor' ,BLACK, ...
                    storage.HGUsingMATLABClasses)
            end
            setGraphicsProperty(labelH, 'color', labelColor, ...
                storage.HGUsingMATLABClasses)
            
            labelH = get(a,'zlabel');
            if ~isempty( labelH )
                labelColor = get(labelH,'color');
                if (isequal(azc,origFigColor))
                    setGraphicsProperty(a, 'zcolor', WHITE, ...
                        storage.HGUsingMATLABClasses)
                elseif (isequal(azc,WHITE))
                    setGraphicsProperty(a, 'zcolor', BLACK, ...
                        storage.HGUsingMATLABClasses)
                end
                setGraphicsProperty(labelH, 'color', labelColor, ...
                    storage.HGUsingMATLABClasses)
            end
        elseif isprop(a, 'TextColor') && isprop(a, 'EdgeColor')
            textColor = get(a, 'TextColor');
            if (isequal(textColor, origFigColor))
                setGraphicsProperty(a, 'TextColor', WHITE, ...
                    storage.HGUsingMATLABClasses)
            elseif (isequal(textColor, WHITE))
                setGraphicsProperty(a, 'TextColor', BLACK, ...
                    storage.HGUsingMATLABClasses)
            end
            
            edgeColor = get(a, 'EdgeColor');
            if (isequal(edgeColor, origFigColor))
                setGraphicsProperty(a, 'EdgeColor', WHITE, ...
                    storage.HGUsingMATLABClasses)
            elseif (isequal(edgeColor, WHITE))
                setGraphicsProperty(a, 'EdgeColor', BLACK, ...
                    storage.HGUsingMATLABClasses)
            end
        end
    end

    %Face and Edge color matrices may not be fully filled out
    used = [];
    if count.facecolor > 0
        used = 1 : count.facecolor;
        used(cellfun('isempty', turnMe.facecolor(:,1))) = [];
    end
    if ~isempty( used )
        storage.facecolor(used(end)+1:end,:) = [];
        for k = used
            setGraphicsProperty(turnMe.facecolor{k,1}, 'facecolor', ...
                turnMe.facecolor{k,2}, storage.HGUsingMATLABClasses);
        end
    else
        storage.facecolor = {};
    end
    
    used = [];
    if count.edgecolor > 0
        used = 1 : count.edgecolor;
        used(cellfun('isempty', turnMe.edgecolor(:,1))) = [];
    end
    if ~isempty( used )
        storage.edgecolor(used(end)+1:end,:) = [];
        for k = used
            setGraphicsProperty(turnMe.edgecolor{k,1}, 'edgecolor', ...
                turnMe.edgecolor{k,2}, storage.HGUsingMATLABClasses);
        end
    else
        storage.edgecolor = {};
    end

    %Marker Face and Edge color matrices may not be fully filled out
    used = [];
    if count.markerfacecolor > 0
        used = 1 : count.markerfacecolor;
        used(cellfun('isempty', turnMe.markerfacecolor(:,1))) = [];
    end
    if ~isempty( used )
        storage.markerfacecolor(used(end)+1:end,:) = [];
        for k = used
            setGraphicsProperty(turnMe.markerfacecolor{k,1}, ...
                'markerfacecolor', turnMe.markerfacecolor{k,2}, ...
                storage.HGUsingMATLABClasses);
        end
    else
        storage.markerfacecolor = {};
    end
    
    used = [];
    if count.markeredgecolor > 0
        used = 1 : count.markeredgecolor;
        used(cellfun('isempty', turnMe.markeredgecolor(:,1))) = [];
    end
    if ~isempty( used )
        storage.markeredgecolor(used(end)+1:end,:) = [];
        for k = used
            setGraphicsProperty(turnMe.markeredgecolor{k,1}, ...
                'markeredgecolor', turnMe.markeredgecolor{k,2}, ...
                storage.HGUsingMATLABClasses);
        end
    else
        storage.markeredgecolor = {};
    end

    % It might become important that this is LAST
    setGraphicsProperty(fig, 'color', WHITE, storage.HGUsingMATLABClasses);

    SaveTonerOriginalColors = [storage SaveTonerOriginalColors];

else % Restore colors

    storage = SaveTonerOriginalColors(1);
    SaveTonerOriginalColors = SaveTonerOriginalColors(2:end);
    origFig = storage.figure{1};
    if storage.HGUsingMATLABClasses ~= ~useOriginalHGPrinting(origFig)
        error(message('MATLAB:adjustbackground:InconsistentClasses'))
    end
    origFigColor = storage.figure{2};
    if (sum(isnan(origFigColor)) == 3)
        origFigColor = 'none';
    end
    setGraphicsProperty(origFig, 'color', origFigColor, ...
        storage.HGUsingMATLABClasses);
    
    for k = 1:size(storage.axes,1)
        a = storage.axes{k,1};
        setGraphicsProperty(a, 'color', matrix2color(storage.axes{k,2}(1:3)), ...
            storage.HGUsingMATLABClasses)
        
        if isprop(a, 'XLabel') && isprop(a, 'YLabel') ...
                && isprop(a, 'ZLabel')
            %When setting axis color, make sure label isn't affected.
            labelH = get(a,'xlabel');
            labelColor = get(labelH,'color');
            setGraphicsProperty(a, 'xcolor', storage.axes{k,2}(4:6), ...
                storage.HGUsingMATLABClasses)
            setGraphicsProperty(labelH, 'color', labelColor, ...
                storage.HGUsingMATLABClasses)
            
            labelH = get(a,'ylabel');
            labelColor = get(labelH,'color');
            setGraphicsProperty(a, 'ycolor', storage.axes{k,2}(7:9), ...
                storage.HGUsingMATLABClasses)
            setGraphicsProperty(labelH, 'color', labelColor, ...
                storage.HGUsingMATLABClasses)
            
            labelH = get(a,'zlabel');
            if ~isempty( labelH )
                labelColor = get(labelH,'color');
                setGraphicsProperty(a, 'zcolor', storage.axes{k,2}(10:12), ...
                    storage.HGUsingMATLABClasses)
                setGraphicsProperty(labelH, 'color', labelColor, ...
                    storage.HGUsingMATLABClasses)
            end
        elseif isprop(a, 'TextColor') && isprop(a, 'EdgeColor')
            setGraphicsProperty(a, 'Color', storage.axes{k,2}(4:6), ...
                storage.HGUsingMATLABClasses)
            setGraphicsProperty(a, 'EdgeColor', storage.axes{k,2}(7:9), ...
                storage.HGUsingMATLABClasses)
            setGraphicsProperty(a, 'TextColor', storage.axes{k,2}(10:12), ...
                storage.HGUsingMATLABClasses)
        end
    end

    for k = 1:size(storage.color,1)
        obj = storage.color{k,1};
        setGraphicsProperty(obj, 'color', ...
            matrix2color(storage.color{k,2}), storage.HGUsingMATLABClasses)
    end

    for k = 1:size(storage.facecolor,1)
        obj = storage.facecolor{k,1};
        setGraphicsProperty(obj, 'facecolor', ...
            matrix2color(storage.facecolor{k,2}), ...
            storage.HGUsingMATLABClasses)
    end

    for k = 1:size(storage.edgecolor,1)
        obj = storage.edgecolor{k,1};
        setGraphicsProperty(obj, 'edgecolor', ...
            matrix2color(storage.edgecolor{k,2}), ...
            storage.HGUsingMATLABClasses)
    end

    for k = 1:size(storage.markeredgecolor,1)
        obj = storage.markeredgecolor{k,1};
        setGraphicsProperty(obj, 'markeredgecolor', ...
            matrix2color(storage.markeredgecolor{k,2}), ...
            storage.HGUsingMATLABClasses)
    end

    for k = 1:size(storage.markerfacecolor,1)
        obj = storage.markerfacecolor{k,1};
        setGraphicsProperty(obj, 'markerfacecolor', ...
            matrix2color(storage.markerfacecolor{k,2}), ...
            storage.HGUsingMATLABClasses)
    end
end

%%%%%%%% nested functions 
%-------------------
function [storage, turnMe, idx] = setfaceedge( obj, newFace, newEdge, storage, turnMe, idx )
%SETFACEEDGE Set both FaceColor and EdgeColor and update structures

if ~isnan(newFace)
    storage.facecolor(idx.facecolor,:) = {obj color2matrix(get(obj,'facecolor')) };
    turnMe.facecolor(idx.facecolor,:) = {obj newFace};
    idx.facecolor = idx.facecolor + 1;
end

if ~isnan(newEdge)
    storage.edgecolor(idx.edgecolor,:) = {obj color2matrix(get(obj,'edgecolor')) };
    turnMe.edgecolor(idx.edgecolor,:) = {obj newEdge};
    idx.edgecolor = idx.edgecolor + 1;
end
end

%-------------------
function [storage, turnMe, idx] = setmfaceedge( obj, newFace, newEdge, storage, turnMe, idx )
%SETMFACEEDGE Set both MarkerFaceColor and MarkerEdgeColor and update structures

if ~isnan(newFace)
    storage.markerfacecolor(idx.markerfacecolor,:) = {obj color2matrix(get(obj,'markerfacecolor')) };
    turnMe.markerfacecolor(idx.markerfacecolor,:) = {obj newFace};
    idx.markerfacecolor = idx.markerfacecolor + 1;
end

if ~isnan(newEdge)
    storage.markeredgecolor(idx.markeredgecolor,:) = {obj color2matrix(get(obj,'markeredgecolor')) };
    turnMe.markeredgecolor(idx.markeredgecolor,:) = {obj newEdge};
    idx.markeredgecolor = idx.markeredgecolor + 1;
end
end

%-------------------
function color = color2matrix( color )
%COLOR2MATRIX Return a 1x3 for any color, including strings 'flat' and 'none'

if isequal(color, 'none' )
    color = NONE;

elseif isequal(color, 'flat' )
    color = FLAT;

end
end

%-------------------
function color = matrix2color( color )
%MATRIX2COLOR Return a Color-spec for any a 1x3, possibly encoded for 'flat' and 'none'.

if isequal(isnan(color), isnan(NONE) )
    color = 'none';

elseif isequal(isnan(color), isnan(FLAT) )
    color = 'flat';

end
end

  %%%%%%%% end nested functions
end


% LocalWords:  contrastness xcolor ycolor zcolor SETFACEEDGE SETMFACEEDGE
% LocalWords:  facecolor edgecolor markeredgecolor markerfacecolor XColor
% LocalWords:  YColor ZColor CONTRASTCOLORS nd XLabel ZLabel
