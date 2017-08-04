function contrastcolors( state, fig )
%CONTRASTCOLORS Modify figure to avoid dithered lines.
%   This undocumented helper function is for internal use.

%   CONTRASTCOLORS(STATE,FIG) modifies the color of graphics objects to
%   black or white, whichever best contrasts the figure and axis
%   colors.  STATE is either 'save' to set up colors for black
%   background or 'restore'.
%
%   CONTRASTCOLORS(STATE) operates on the current figure.
%
%   See also ADJUSTBACKGROUND, BWCONTR, PRINT

%   Copyright 1984-2013 The MathWorks, Inc.
    
    if nargin == 0 ...
            || ~ischar( state ) ...
            || ~(strcmp(state, 'save') || strcmp(state, 'restore'))
        error(message('MATLAB:contrastcolors:invalidFirstArgument'))
    elseif nargin ==1
        fig = gcf;
    end
    
    persistent NoDitherOriginalColors;
    
    if strcmp(get(fig,'color'),'none')
        return % Don't do anything -- Assume all users of 'none' have already
        % mapped their colors if so desired.
    end
    
    BLACK = [0 0 0];
    WHITE = [1 1 1];
    
    if strcmp( state, 'save' )
        
        % initialize objects
        di.axesObj = [];
        di.lineObj = [];
        di.surfaceObj = [];
        di.textObj = [];
        di.rectObj = [];
        di.patchObj = [];
        di.annotObj = [];
        di.otherObj = [];
        
        figColor = get(fig,'color');
        figContrast = bwcontr(figColor);
        otherObjs = [];
        allAxes = findall( fig, 'Type', 'axes',   '-or', ...
                                'Type', 'legend', '-or', ...
                                'Type', 'colorbar');
        naxes = length(allAxes);
        for k = 1:naxes
            a = allAxes(k);
            
            if isprop(a, 'Color') && isprop(a, 'XColor') && ...
                    isprop(a, 'YColor') && isprop(a, 'ZColor')
                axColor = get(a,'Color');
                if (isequal(axColor,'none'))
                    axContrast = figContrast;
                else
                    axContrast = bwcontr(axColor);
                end
           
                saveAndChangeAxisColors(a, k)

                % Change the various plot object colors
                saveAndChangeLineColors(a)
                saveAndChangeSurfacePlotColors(a)
                saveAndChangeTextColors(a)
                saveAndChangeRectangleColors(a)
                saveAndChangePatchColors(a)
            elseif ~useOriginalHGPrinting()
                % Save other objects (legends, color bars, etc...) to
                % process after axes, since their colors may be based off
                % of the axis colors.
                otherObjs(length(otherObjs)+1) = a; %#ok<AGROW>
            end
        end
        
        if ~isempty(otherObjs)
            % Handle other objects (legends, color bars, etc...) which may
            % not have the X/Y/Z Color properties
            for j=1:length(otherObjs)
                obj = otherObjs(j);
                
                saveAndChangeOtherObjColors(obj);
            end
        end
        
        % Change Other objects if necessary (annotation, etc...)
        if ~useOriginalHGPrinting()
            saveAndChangeAnnotationColors(fig);
        end
        
        % Save for restoration later
        NoDitherOriginalColors = [di NoDitherOriginalColors];
        
    else  
        % Restore the colors to the original state
        orig = NoDitherOriginalColors(1);
        NoDitherOriginalColors = NoDitherOriginalColors(2:end);
        
        restoreLineColors()
        restoreAxesColors()
        restorePatchColors()
        restoreSurfacePlotColors()
        restoreTextColors()
        restoreRectangleColors()
        
        if ~useOriginalHGPrinting()
            restoreAnnotationColors()
            restoreOtherObjColors()
        end
    end
    
    %----------------------------------------------------------------     
    function saveAndChangeAxisColors(a, index)
        % Make sure that X-, Y-, and ZColors are one of:
        %   - white
        %   - black
        %   - figColor
        %   - figContrast        
        di.axesObj(index).axesObject = a;
        axc = get(a,'XColor');
        ayc = get(a,'YColor');
        azc = get(a,'ZColor');
        
        di.axesObj(index).xColor = axc;
        di.axesObj(index).yColor = ayc;
        di.axesObj(index).zColor = azc;
        
        if isprop(a, 'XColorMode') && isprop(a, 'YColorMode') && ...
                isprop(a, 'ZColorMode') && isprop(a, 'GridColorMode')
            di.axesObj(index).xColorMode = get(a, 'XColorMode');
            di.axesObj(index).yColorMode = get(a, 'YColorMode');
            di.axesObj(index).zColorMode = get(a, 'ZColorMode');
            di.axesObj(index).gridColorMode = get(a, 'GridColorMode');
        end
        
        if (~isequal(axc,BLACK) && ~isequal(axc,WHITE) && ~isequal(axc,figColor))
            set(a,'XColor',figContrast)
        end
        if (~isequal(ayc,BLACK) && ~isequal(ayc,WHITE) && ~isequal(ayc,figColor))
            set(a,'YColor',figContrast)
        end
        if (~isequal(azc,BLACK) && ~isequal(azc,WHITE) && ~isequal(azc,figColor))
            set(a,'ZColor',figContrast)
        end
        
        % If the axis has a GridColor property, it won't be used unless
        % both the GridColorMode & XColorMode are manual.  Just changing
        % the XColor, like we've done above, has the result of the axis
        % grid color being displayed with the X/Y/Z colors set above.  But
        % if the GridColor is default to begin with, it looks better if it
        % stays at the default (gray: [0.85 0.85 0.85])
        if (isprop(a, 'GridColor'))
            xGridColor = get(a, 'GridColor');
            defaultGridColor = get(a, 'DefaultAxesGridColor');
            if all(xGridColor == defaultGridColor)
                set(a, 'GridColor', 1-defaultGridColor); % set off-default to force the mode change
                set(a, 'GridColor', defaultGridColor);   % set default
            end
        end
    end
    
    %----------------------------------------------------------------
    function restoreAxesColors()
        % Restore axes
        for n = 1:length(orig.axesObj)
            a = orig.axesObj(n).axesObject;
            if ~strcmp(get(a,'tag'), 'legend')
                axc = orig.axesObj(n).xColor;
                ayc = orig.axesObj(n).yColor;
                azc = orig.axesObj(n).zColor;
                set(a,'XColor',axc)
                set(a,'YColor',ayc)
                set(a,'ZColor',azc)
                
                if isscalar(a) && ...
                        isprop(a, 'XColorMode') && ...
                        isprop(a, 'YColorMode') &&  ...
                        isprop(a, 'ZColorMode') && ...
                        isprop(a, 'GridColorMode')
                    
                    xcm = orig.axesObj(n).xColorMode;
                    ycm = orig.axesObj(n).yColorMode;
                    zcm = orig.axesObj(n).zColorMode;
                    gcm = orig.axesObj(n).gridColorMode;
                    
                    set(a, 'XColorMode', xcm);
                    set(a, 'YColorMode', ycm);
                    set(a, 'ZColorMode', zcm);
                    set(a, 'GridColorMode', gcm);
                end
            end
        end
    end
    
    %----------------------------------------------------------------     
    function saveAndChangeLineColors(a)
        lobjs = findall(a,'type','line','Visible','on');
        nlobjs = length(lobjs);
        already.line = length(di.lineObj);
        
        for n = 1:nlobjs
            l = lobjs(n);
            lcolor = get(l,'color');
            lmecolor = get(l,'markeredgecolor');
            lmfcolor = get(l,'markerfacecolor');
            idx = already.line+n;
            
            % Save the line and its current colors for the restore
            di.lineObj(idx).lineObject = l;
            di.lineObj(idx).color = lcolor;
            di.lineObj(idx).markerEdgeColor = lmecolor;
            di.lineObj(idx).markerFaceColor = lmfcolor;
            
            if isprop(l, 'ColorMode') && isprop(l, 'MarkerEdgeColorMode') ...
                    && isprop(l, 'MarkerFaceColorMode')
                di.lineObj(idx).colorMode = get(l, 'ColorMode');
                di.lineObj(idx).markerEdgeColorMode = get(l, 'MarkerEdgeColorMode');
                di.lineObj(idx).markerFaceColorMode = get(l, 'MarkerFaceColorMode');
            end
            
            if (~isequal(lcolor,BLACK) && ~isequal(lcolor,WHITE) && ...
                    ~isequal(lcolor,axColor))
                set(l,'color',axContrast)
            end
            
            if ~ischar(lmfcolor) && ~isequal(lmfcolor,BLACK) && ...
                    ~isequal(lmfcolor,WHITE) && ~isequal(lmfcolor,axColor)
                if (isequal(lmfcolor,axContrast))
                    set(l,'markerfacecolor',1-axContrast)
                else
                    set(l,'markerfacecolor',axContrast)
                end
            end
            
            %Don't change EdgeColor if it's one of the strings
            %  or the same color as the face itself.
            if ~ischar(lmecolor) && ~isequal(lmecolor,BLACK) && ...
                    ~isequal(lmecolor,WHITE) && ~isequal(lmecolor,axColor)
                if ~isequal( lmecolor, get(l,'markerfacecolor') )
                    if (isequal(lmfcolor,axContrast))
                        set(l,'markeredgecolor',1-axContrast)
                    else
                        set(l,'markeredgecolor',axContrast)
                    end
                end
            end
        end
    end

    %----------------------------------------------------------------
    function restoreLineColors
        % Restore lines
        for n = 1:length(orig.lineObj)
            l = orig.lineObj(n).lineObject;
            lcolor = orig.lineObj(n).color;
            lmecolor = orig.lineObj(n).markerEdgeColor;
            lmfcolor = orig.lineObj(n).markerFaceColor;
            
            set(l,'color',lcolor )
            set(l,'markeredgecolor',lmecolor )
            set(l,'markerfacecolor',lmfcolor)
            
            if isprop(l, 'ColorMode') && isprop(l, 'MarkerEdgeColorMode') ...
                    && isprop(l, 'MarkerFaceColorMode')
                set(l, 'ColorMode', orig.lineObj(n).colorMode);
                set(l, 'MarkerEdgeColorMode', orig.lineObj(n).markerEdgeColorMode);
                set(l, 'MarkerFaceColorMode', orig.lineObj(n).markerFaceColorMode); 
            end
        end
    end
    
    %----------------------------------------------------------------     
    function saveAndChangeSurfacePlotColors(a)
        sobjs = findall(a,'type','surface','Visible','on');
        nsobjs = length(sobjs);
        already.surface = length(di.surfaceObj);
        
        for n = 1:nsobjs
            s = sobjs(n);
            secolor = get(s,'edgecolor');
            sfcolor = get(s,'facecolor');
            smecolor = get(s,'markeredgecolor');
            smfcolor = get(s,'markerfacecolor');
            idx = already.surface+n;
            
            % Save the surface plot and its current colors for the restore
            di.surfaceObj(idx).surfaceObject = s;
            di.surfaceObj(idx).edgeColor = secolor;
            di.surfaceObj(idx).faceColor = sfcolor;
            di.surfaceObj(idx).markerEdgeColor = smecolor;
            di.surfaceObj(idx).markerFaceColor = smfcolor;
            
            if isprop(s, 'EdgeColorMode') && isprop(s, 'FaceColorMode') && ...
                    isprop(s, 'MarkerEdgeColorMode') && ...
                    isprop(s, 'MarkerFaceColorMode')
                
                di.surfaceObj(idx).edgeColorMode = get(s, 'EdgeColorMode');
                di.surfaceObj(idx).faceColorMode = get(s, 'FaceColorMode');
                di.surfaceObj(idx).markerEdgeColorMode = get(s, 'MarkerEdgeColorMode');
                di.surfaceObj(idx).markerFaceColorMode = get(s, 'MarkerFaceColorMode');
            end

            edgesUseCdata = strcmp(secolor,'flat') | strcmp(secolor,'interp');
            %       markerEdgesUseCdata = strcmp(smecolor,'flat') | ...
            % 	  (strcmp(smecolor,'auto') & edgesUseCdata);
            nanInCdata = any(find(isnan(get(s, 'cdata'))));
            
            %Don't change EdgeColor if it is
            % a) it is the same as the FaceColor
            % b) is None
            % c) is same as the Axes background
            % d) it is Black or White
            % e) the edges use cdata and there is a nan in the cdata
            if ~( isequal(secolor, sfcolor) || strcmp(secolor,'none') || isequal(secolor,axColor) ...
                    || isequal(secolor,BLACK) || isequal(secolor,WHITE) ...
                    || (edgesUseCdata && nanInCdata))
                if (isequal(sfcolor,axContrast))
                    set(s,'edgecolor',1-axContrast)
                else
                    set(s,'edgecolor',axContrast)
                end
                edgecolormapped = 1;
            else
                edgecolormapped = 0;
            end
            
            %Look for surfaces that want to be treated like lines. All
            %surfaces where the AppData property 'NoDither' exists and is
            %set to 'on' are treated like lines.
            if isappdata(s,'NoDither') && strcmp(getappdata(s,'NoDither'),'on')
                if (~isequal(sfcolor,BLACK) && ~isequal(sfcolor,WHITE) && ...
                        ~isequal(sfcolor,axColor))
                    set(s,'facecolor',axContrast)
                end
                if (~isequal(secolor,BLACK) && ~isequal(secolor,WHITE) && ...
                        ~isequal(secolor,axColor))
                    set(s,'edgecolor',axContrast)
                end
            end
            
            %Don't change EdgeColor if it is
            % a) it is the same as the FaceColor
            % b) is None
            % c) is same as the Axes background
            % d) it is Black or White
            % e) the markeredges are flat and the edges weren't mapped
            % f) the markeredges are auto and the edges weren't mapped
            if ~strcmp(smecolor,'none') && ...
                    ~isequal(smecolor,sfcolor) && ~isequal(smecolor,BLACK) && ...
                    ~isequal(smecolor,WHITE) && ~isequal(smecolor,axColor) && ...
                    ~(strcmp(smecolor,'auto') && ~edgecolormapped) && ...
                    ~(strcmp(smecolor,'flat') && ~edgecolormapped)
                if (isequal(smfcolor,axContrast))
                    set(s,'markeredgecolor',1-axContrast)
                else
                    set(s,'markeredgecolor',axContrast)
                end
            end
            
            %Don't change MarkerFaceColor if it is
            % a) same as the FaceColor
            % b) None
            % c) same as the Axes Background
            % d) Black or White
            % e) the marker faces are auto and the edges weren't mapped
            if ~strcmp(smfcolor,'none') && ...
                    ~isequal(smfcolor,sfcolor) && ~isequal(smfcolor,BLACK) && ...
                    ~isequal(smfcolor,WHITE) && ~isequal(smfcolor,axColor) && ...
                    ~(strcmp(smfcolor,'auto') && ~edgecolormapped) && ...
                    ~(strcmp(smfcolor,'flat') && ~edgecolormapped)
                if (isequal(smfcolor,axContrast))
                    set(s,'markerfacecolor',1-axContrast)
                else
                    set(s,'markerfacecolor',axContrast)
                end
            end
        end
    end
    
    %----------------------------------------------------------------
    function restoreSurfacePlotColors()
        % Restore surface objects
        for n = 1:length(orig.surfaceObj)
            s = orig.surfaceObj(n).surfaceObject;
            sfcolor = orig.surfaceObj(n).faceColor;
            secolor = orig.surfaceObj(n).edgeColor;
            smecolor = orig.surfaceObj(n).markerEdgeColor;
            smfcolor = orig.surfaceObj(n).markerFaceColor;
            
            set(s,'facecolor',sfcolor)
            set(s,'edgecolor',secolor)
            set(s,'markeredgecolor',smecolor)
            set(s,'markerfacecolor',smfcolor)
            
            if isprop(s, 'EdgeColorMode') && isprop(s, 'FaceColorMode') && ...
                    isprop(s, 'MarkerEdgeColorMode') && ...
                    isprop(s, 'MarkerFaceColorMode')
                set(s,'EdgeColorMode', orig.surfaceObj(n).edgeColorMode)
                set(s,'FaceColorMode', orig.surfaceObj(n).faceColorMode)
                set(s,'MarkerEdgeColorMode', orig.surfaceObj(n).markerEdgeColorMode)
                set(s,'MarkerFaceColorMode', orig.surfaceObj(n).markerFaceColorMode)
            end
        end
    end
    
    %----------------------------------------------------------------
    function saveAndChangeTextColors(a)
        tobjs = findall(a,'type','text','Visible','on');
        ntobjs = length(tobjs);
        
        if ntobjs > 0
            already.text = length(di.textObj);
            
            if isprop(a, 'XLabel') && isprop(a, 'YLabel') && ...
                    isprop(a, 'ZLabel') && isprop(a, 'Title')
                aLabels = get(a, {'XLabel';'YLabel';'ZLabel';'Title'});
                aLabels = cat(1, aLabels{:})'; % turn cell array into row vector
            else
                aLabels = [];
            end
            for n = 1:ntobjs
                t = tobjs(n);
                tcolor = get(t,'color');
                idx = already.text+n;
                
                di.textObj(idx).textObject = t;
                di.textObj(idx).color = tcolor;
                if isprop(t, 'ColorMode')
                    di.textObj(idx).colorMode = get(t, 'ColorMode');
                end
                
                if (~isequal(tcolor,BLACK) && ~isequal(tcolor,WHITE) )
                    if find(t==aLabels)
                        %This will fail if user positions labels within Axis
                        %so that is must contrast a different color then figColor.
                        if ~isequal(tcolor,figColor)
                            set(t,'color',figContrast)
                        end
                    else
                        if ~isequal(tcolor,axColor)
                            bkColor = get(t, 'BackgroundColor');
                            if isequal(bkColor, axContrast)
                                % If the background color of the text is
                                % the same as the axis contrast color,
                                % don't set the text to it, otherwise the
                                % text color and background color will be
                                % the same, and the text will not be
                                % visible.  Use a contrasting color of the
                                % background color instead.
                                set(t, 'Color', bwcontr(bkColor));
                            else
                                set(t, 'color', axContrast)
                            end
                        end
                    end
                end
            end
        end
    end
   
    %----------------------------------------------------------------
    function restoreTextColors()
        % Restore text objects
        for n = 1:length(orig.textObj)
            t = orig.textObj(n).textObject;
            tcolor = orig.textObj(n).color;
            set(t,'color',tcolor)
            
            if isprop(t, 'ColorMode')
                set(t, 'ColorMode', orig.textObj(n).colorMode);
            end
        end
    end
    
    %---------------------------------------------------------------- 
    function saveAndChangeRectangleColors(a)
        robjs = findall(a,'type','rectangle','Visible','on');
        nrobjs = length(robjs);
        already.rect = length(di.rectObj);
        
        for n = 1:nrobjs
            r = robjs(n);
            recolor = get(r,'edgecolor');
            rfcolor = get(r,'facecolor');
            idx = already.rect+n;
            
            % contrastcolors doesn't change the Rectangle FaceColor, so
            % although we retrieve the value above, we don't need to save
            % it in the rectObj struct for the restore.  Similarly, we
            % don't need to save the FaceColorMode if it is a property of
            % the rectangle object.
            di.rectObj(idx).rectObject = r;
            di.rectObj(idx).edgeColor = recolor;
            if isprop(r, 'EdgeColorMode')
                di.rectObj(idx).edgeColorMode = get(r, 'EdgeColorMode');
            end
            
            %Don't change EdgeColor if it is:
            % a) it is the same as the FaceColor
            % b) is None
            % c) is same as the Axes background
            % b) it is Black or White
            if ~( isequal(recolor, rfcolor) || strcmp(recolor,'none') || isequal(recolor,axColor) ...
                    || isequal(recolor,BLACK) || isequal(recolor,WHITE) )
                if (isequal(rfcolor,axContrast))
                    set(r,'edgecolor',1-axContrast)
                else
                    set(r,'edgecolor',axContrast)
                end
            end
        end
    end
    
    %----------------------------------------------------------------
    function restoreRectangleColors()
        % Restore rectangles
        for n = 1:length(orig.rectObj)
            r = orig.rectObj(n).rectObject;
            rcolor = orig.rectObj(n).edgeColor;
            
            set(r,'edgecolor',rcolor)
            if isprop(r, 'EdgeColorMode')
                set(r, 'EdgeColorMode', orig.rectObj(n).edgeColorMode);
            end
        end
    end
    
    %----------------------------------------------------------------
    function saveAndChangePatchColors(a)
        pobjs = findall(a,'type','patch','Visible','on');
        npobjs = length(pobjs);
        already.patch = length(di.patchObj);
        
        for n = 1:npobjs
            p = pobjs(n);
            pecolor = get(p,'edgecolor');
            pfcolor = get(p,'facecolor');
            pmecolor = get(p,'markeredgecolor');
            pmfcolor = get(p,'markerfacecolor');
            idx = already.patch+n;
            
            % Save the patch object and its current colors for the restore
            di.patchObj(idx).patchObject = p;
            di.patchObj(idx).edgeColor = pecolor;
            di.patchObj(idx).faceColor = pfcolor;
            di.patchObj(idx).markerEdgeColor = pmecolor;
            di.patchObj(idx).markerFaceColor = pmfcolor;
            
            if isprop(p, 'EdgeColorMode') && isprop(p, 'FaceColorMode') && ...
                    isprop(p, 'MarkerEdgeColorMode') && ...
                    isprop(p, 'MarkerFaceColorMode')
                di.patchObj(idx).edgeColorMode = get(p, 'EdgeColorMode');
                di.patchObj(idx).faceColorMode = get(p, 'FaceColorMode');
                di.patchObj(idx).markerEdgeColorMode = get(p, 'MarkerEdgeColorMode');
                di.patchObj(idx).markerFaceColorMode = get(p, 'MarkerFaceColorMode');
            end
            
            edgesUseCdata = strcmp(pecolor,'flat') | strcmp(pecolor,'interp');
            %       markerEdgesUseCdata = strcmp(pmecolor,'flat') | ...
            % 	  (strcmp(pmecolor,'auto') & edgesUseCdata);
            XdatananPos = isnan(get(p, 'xdata'));
            CdatananPos = isnan(get(p, 'cdata'));
            nanInCdata = any(CdatananPos(:));
            
            %Don't change EdgeColor if it is:
            % a) it is the same as the FaceColor
            % b) is None
            % c) is same as the Axes background
            % d) it is Black or White
            % e) the edges use cdata and there is a nan in the
            %    cdata and the position of the nans in the cdata
            %    and xdata differ (Contour plots have nans in cdata
            %    and vertices in the same positions -> we do want
            %    to change the edgecolors to black. But we do not
            %    want edges with nans in cdata without a corresponding
            %    nan in the vertices to suddenly appear when printing.)
            if ~( isequal(pecolor, pfcolor) || strcmp(pecolor,'none') || ...
                    isequal(pecolor,axColor) ...
                    || isequal(pecolor,BLACK) || isequal(pecolor,WHITE) ...
                    || (edgesUseCdata && nanInCdata && ~isequal(XdatananPos, CdatananPos)))
                if (isequal(pfcolor,axContrast))
                    set(p,'edgecolor',1-axContrast)
                else
                    set(p,'edgecolor',axContrast)
                end
                edgecolormapped = 1;
            else
                edgecolormapped = 0;
            end
            
            %Look for patches that want to be treated like lines
            %(e.g. arrow heads).  All patches where the AppData property
            %'NoDither' exists and is set to 'on' are treated like lines.
            if isappdata(p,'NoDither') && strcmp(getappdata(p,'NoDither'),'on')
                if (~isequal(pfcolor,BLACK) && ~isequal(pfcolor,WHITE) && ...
                        ~isequal(pfcolor,axColor))
                    set(p,'facecolor',axContrast)
                end
                if (~isequal(pecolor,BLACK) && ~isequal(pecolor,WHITE) && ...
                        ~isequal(pecolor,axColor))
                    set(p,'edgecolor',axContrast)
                end
            end
            
            %Don't change EdgeColor if it is
            % a) it is the same as the FaceColor
            % b) is None
            % c) is same as the Axes background
            % d) it is Black or White
            % e) the markeredges are flat and the edges weren't mapped
            % f) the marker edges are auto and the edges weren't mapped
            if ~strcmp(pmecolor,'none') && ...
                    ~isequal(pmecolor,pfcolor) && ~isequal(pmecolor,BLACK) && ...
                    ~isequal(pmecolor,WHITE) && ~isequal(pmecolor,axColor) && ...
                    ~(strcmp(pmecolor,'auto') && ~edgecolormapped) && ...
                    ~(strcmp(pmecolor,'flat') && ~edgecolormapped)
                if (isequal(pmfcolor,axContrast))
                    set(p,'markeredgecolor',1-axContrast)
                else
                    set(p,'markeredgecolor',axContrast)
                end
            end
            
            %Don't change MarkerFaceColor if it is
            % a) same as the FaceColor
            % b) None
            % c) same as the Axes Background
            % d) Black or White
            % e) the marker faces are auto and the edges weren't mapped
            if ~strcmp(pmfcolor,'none') && ...
                    ~isequal(pmfcolor,pfcolor) && ~isequal(pmfcolor,BLACK) && ...
                    ~isequal(pmfcolor,WHITE) && ~isequal(pmfcolor,axColor) && ...
                    ~(strcmp(pmfcolor,'auto') && ~edgecolormapped) && ...
                    ~(strcmp(pmfcolor,'flat') && ~edgecolormapped)
                if (isequal(pmfcolor,axContrast))
                    set(p,'markerfacecolor',1-axContrast)
                else
                    set(p,'markerfacecolor',axContrast)
                end
            end
        end
    end
    
    %----------------------------------------------------------------
    function restorePatchColors()
        % Restore patch objects
        for n = 1:length(orig.patchObj)
            p = orig.patchObj(n).patchObject;
            sfcolor = orig.patchObj(n).faceColor;
            secolor = orig.patchObj(n).edgeColor;
            smecolor = orig.patchObj(n).markerEdgeColor;
            smfcolor = orig.patchObj(n).markerFaceColor;
            
            set(p,'facecolor',sfcolor)
            set(p,'edgecolor',secolor)
            set(p,'markeredgecolor',smecolor)
            set(p,'markerfacecolor',smfcolor)
            
            if isprop(p, 'EdgeColorMode') && isprop(p, 'FaceColorMode') && ...
                    isprop(p, 'MarkerEdgeColorMode') && ...
                    isprop(p, 'MarkerFaceColorMode')
                set(p, 'EdgeColorMode', orig.patchObj(n).edgeColorMode);
                set(p, 'FaceColorMode', orig.patchObj(n).faceColorMode);
                set(p, 'MarkerEdgeColorMode', orig.patchObj(n).markerEdgeColorMode);
                set(p, 'MarkerFaceColorMode', orig.patchObj(n).markerFaceColorMode);
            end
        end
    end
        
    %----------------------------------------------------------------
    function saveAndChangeAnnotationColors(fig)
        objs = findall(fig, {'Type','hggroup',...
                             'Type','arrowshape','-or',...
 	                         'Type','doubleendarrowshape','-or',...
 	                         'Type','textarrowshape','-or',...
 	                         'Type','lineshape','-or',...
 	                         'Type','ellipseshape','-or',...
 	                         'Type','rectangleshape','-or',...
 	                         'Type','textboxshape'},...
 	                         'Visible','on');
        
        naobjs = length(objs);
        already.annot = length(di.annotObj);
        
        for n = 1:naobjs
            aObj = objs(n);
            idx = already.annot+n;
            di.annotObj(idx).annotObject = aObj;
            
            if isprop(aObj, 'Color')
                acolor = get(aObj,'Color');
                di.annotObj(idx).color = acolor;
                if isprop(aObj, 'ColorMode')
                    di.annotObj(idx).colorMode = get(aObj, 'ColorMode');
                end
                
                if (~isequal(acolor,BLACK) && ~isequal(acolor,WHITE) && ...
                        ~isequal(acolor,axColor))
                    set(aObj,'Color', axContrast)
                end
            else
                acolor = nan;
                di.annotObj(idx).color = nan;
            end
            
            if isprop(aObj, 'TextColor')
                atcolor = get(aObj,'TextColor');
                di.annotObj(idx).textColor = atcolor;
                if isprop(aObj, 'TextColorMode')
                    di.annotObj(idx).textColorMode = get(aObj, 'TextColorMode');
                end
                
                if (~isequal(atcolor, BLACK) && ~isequal(atcolor, WHITE))
                    if ~isequal(atcolor, axColor)
                        set(aObj,'TextColor', axContrast)
                    end
                end
            else
                di.annotObj(idx).textColor = nan;
            end
                       
            if isprop(aObj, 'TextEdgeColor')
                atecolor = get(aObj, 'TextEdgeColor');
                di.annotObj(idx).textEdgeColor = atecolor;
                if isprop(aObj, 'TextEdgeColorMode')
                    di.annotObj(idx).textEdgeColorMode = get(aObj, 'TextEdgeColorMode');
                end
                
                % Don't change TextEdgeColor if it is:
                % a) it is the same as the FaceColor
                % b) is None
                % c) is same as the Axes background
                % b) it is Black or White
                if ~( isequal(atecolor, acolor) || strcmp(atecolor,'none') || isequal(atecolor,axColor) ...
                        || isequal(atecolor,BLACK) || isequal(atecolor,WHITE) )
                    if (isequal(acolor ,axContrast))
                        set(aObj, 'TextEdgeColor', 1-axContrast)
                    else
                        set(aObj, 'TextEdgeColor', axContrast)
                    end
                end
            else
                di.annotObj(idx).textEdgeColor = nan;
            end
        end
    end
    
    %----------------------------------------------------------------
    function restoreAnnotationColors()
        % Restore annotation objects
        for n = 1:length(orig.annotObj)
            a = orig.annotObj(n).annotObject;
            acolor = orig.annotObj(n).color;
            atcolor = orig.annotObj(n).textColor;
            atecolor = orig.annotObj(n).textEdgeColor;
            
            % Color & ColorMode
            if isprop(a, 'Color') && ~any(isnan(acolor))
                set(a, 'Color', acolor)

                if isprop(a, 'ColorMode')
                    set(a, 'ColorMode', orig.annotObj(n).colorMode)
                end
            end

            % TextEdgeColor & TextEdgeColorMode
            if isprop(a, 'TextEdgeColor') && ~any(isnan(atecolor))
                set(a, 'TextEdgeColor', atecolor)
                
                if isprop(a, 'TextEdgeColorMode')
                    set(a, 'TextEdgeColorMode', orig.annotObj(n).textEdgeColorMode)
                end
            end
            
            % TextColor & TextColorMode
            if isprop(a, 'TextColor') && ~any(isnan(atcolor))
                set(a, 'TextColor', atcolor)
                
                if isprop(a, 'TextColorMode')
                    set(a, 'TextColorMode', orig.annotObj(n).textColorMode)
                end
            end
        end
    end
    
    %----------------------------------------------------------------
    function saveAndChangeOtherObjColors(objs)
        % Handle other objects (legends, color bars, etc...) which may
        % not have the X/Y/Z Color properties
        noobjs = length(objs);
        already.other = length(di.otherObj);
        
        for n = 1:noobjs
            obj = objs(n);
            idx = already.other+n;
            di.otherObj(idx).otherObject = obj;
            
            acolor = nan;
            di.otherObj(idx).color = nan;
            
            if isprop(obj, 'TextColor')
                atcolor = get(obj,'TextColor');
                di.otherObj(idx).textColor = atcolor;
                if isprop(obj, 'TextColorMode')
                    di.otherObj(idx).textColorMode = get(obj, 'TextColorMode');
                end
                
                if (~isequal(atcolor, BLACK) && ~isequal(atcolor, WHITE))
                    if ~isequal(atcolor, axColor)
                        set(obj, 'TextColor', axContrast)
                    end
                end
            else
                di.otherObj(idx).textColor = nan;
            end
            
            if isprop(obj, 'EdgeColor')
                atecolor = get(obj, 'EdgeColor');
                di.otherObj(idx).edgeColor = atecolor;
                if isprop(obj, 'EdgeColorMode')
                    di.otherObj(idx).edgeColorMode = get(obj, 'EdgeColorMode');
                end
                
                % Don't change EdgeColor if it is:
                % a) it is the same as the FaceColor
                % b) is None
                % c) is same as the Axes background
                % b) it is Black or White
                if ~( isequal(atecolor, acolor) || strcmp(atecolor,'none') || isequal(atecolor,axColor) ...
                        || isequal(atecolor,BLACK) || isequal(atecolor,WHITE) )
                    if (isequal(acolor ,axContrast))
                        set(obj, 'EdgeColor', 1-axContrast)
                    else
                        set(obj, 'EdgeColor', axContrast)
                    end
                end
            else
                di.otherObj(idx).textEdgeColor = nan;
            end
        end
    end
    
    %----------------------------------------------------------------
    function restoreOtherObjColors()
        % Restore other objects (legends, colorbars, etc...)
        for n = 1:length(orig.otherObj)
            a = orig.otherObj(n).otherObject;
            atcolor = orig.otherObj(n).textColor;
            atecolor = orig.otherObj(n).edgeColor;
            
            % EdgeColor & EdgeColorMode
            if isprop(a, 'EdgeColor') && ~any(isnan(atecolor))
                set(a, 'EdgeColor', atecolor)
                
                if isprop(a, 'EdgeColorMode')
                    set(a, 'EdgeColorMode', orig.otherObj(n).edgeColorMode)
                end
            end
  
            % TextColor & TextColorMode
            if isprop(a, 'TextColor') && ~any(isnan(atcolor))
                set(a, 'TextColor', atcolor)
                
                if isprop(a, 'TextColorMode')
                    set(a, 'TextColorMode', orig.otherObj(n).textColorMode);
                end
            end
        end
    end 
end

% LocalWords:  ZColors xcolor ycolor zcolor facecolor edgecolor markeredge
% LocalWords:  markeredgecolor markerfacecolor pmecolor xdata edgecolors XLabel
% LocalWords:  markeredges texturemap smecolor ADJUSTBACKGROUND colorbars
% LocalWords:  XColor YColor ZColor ZLabel
