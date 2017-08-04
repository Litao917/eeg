classdef Icon < handle
    % Image Icon
    %
    % Constructor:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.Icon">Icon</a>    
    %
    % Properties:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.Description">Description</a>
    %
    % Methods:
    %   <a href="matlab:help matlab.ui.internal.toolstrip.Icon.showStandardIcons">showStandardIcons</a>
    %
    % See also matlab.ui.internal.toolstrip.PushButton, matlab.ui.internal.toolstrip.ListItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent)
        % Property "Description": 
        %
        %   The description of the icon.
        %   It is a string and the default value is the full path.
        %   It is writable.
        Description
    end
    
    properties (Access = private)
        ImageFile
        ImageIcon
        IsCSS
    end
    
    % ----------------------------------------------------------------------------
    methods
        
        %% Constructor
        function this = Icon(source, description)
            % Constructor "Icon": 
            %
            %   (1) Construct a standard icon
            %
            %   Example:
            %       icon = matlab.ui.internal.toolstrip.Icon.ADD_24;
            %       icon = matlab.ui.internal.toolstrip.Icon.NEW_16;
            %
            %   Use matlab.ui.internal.toolstrip.Icon.showStandardIcons()
            %   to browse the list of available standard icons.
            %
            %   (2) Construct a custom icon from an image file
            %
            %   Example:
            %       source = fullfile(matlabroot, 'toolbox', 'shared', 'controllib', 'general', 'resources', 'run.png');
            %       description = 'My icon';
            %       icon = matlab.ui.internal.toolstrip.Icon(source)
            %       icon = matlab.ui.internal.toolstrip.Icon(source, description)
            %
            %   (3) Construct a custom icon from a CSS class
            %
            %   Example:
            %       cssClassName = 'activeStar';
            %       description = 'My css icon';
            %       icon = matlab.ui.internal.toolstrip.Icon(cssClassName)
            %       icon = matlab.ui.internal.toolstrip.Icon(cssClassName, description)
            
            narginchk(1,2)
            if nargin == 1
                if ischar(source)
                    if exist(source, 'file')
                        if strcmpi(source(end-2:end),'jpg') || strcmpi(source(end-2:end),'png')
                            % Icon(imagefile)
                            this.IsCSS = false;
                            this.ImageFile = source;
                            this.ImageIcon = javaObjectEDT('javax.swing.ImageIcon',source);
                        else
                            error(message('MATLAB:toolstrip:general:wrongImageFileFormat'));
                        end
                    else
                        % Icon(css)
                        this.IsCSS = true;
                        this.ImageFile = source;
                        this.ImageIcon = javaObjectEDT('javax.swing.ImageIcon');
                        msg = message('MATLAB:toolstrip:general:customCSS', source);
                        this.Description = msg.getString();
                    end
                else
                    error(message('MATLAB:toolstrip:general:wrongIconFirstInput'));
                end
            elseif nargin == 2
                if ischar(source) && ischar(description)
                    if exist(source, 'file')
                        if strcmpi(source(end-2:end),'jpg') || strcmpi(source(end-2:end),'png')
                            % Icon(imagefile, description)
                            this.IsCSS = false;
                            this.ImageFile = source;
                            this.ImageIcon = javaObjectEDT('javax.swing.ImageIcon', source);
                            this.Description = description;
                        else
                            error(message('MATLAB:toolstrip:general:wrongImageFileFormat'));
                        end
                    else
                        % Icon(css, description)
                        this.IsCSS = true;
                        this.ImageFile = source;
                        this.ImageIcon = javaObjectEDT('javax.swing.ImageIcon');
                        this.Description = description;
                    end
                else
                    error(message('MATLAB:toolstrip:general:wrongIconSecondInput'));
                end
            end
        end
        
        %% Public API: Get/Set
        % Description
        function value = get.Description(this)
            % GET function for Description property.
            value = char(this.ImageIcon.getDescription);
        end
        function set.Description(this, value)
            % SET function for Description property.
            if ~matlab.ui.internal.toolstrip.base.Utility.validate(value, 'string')
                error(message('MATLAB:toolstrip:general:invalidIconDescription'))
            end
            this.ImageIcon.setDescription(value);
        end
        
    end
    
    % ----------------------------------------------------------------------------
    methods (Static)
        
        function showStandardIcons()
            % Method "showStandardIcons"
            % 
            %   Display all the available standard icons with their names.
            %   
            %   You must have network access to the intra-net at MathWorks.
            address = 'http://inside-labs-dev.mathworks.com/sandbox/rsehgal/Toolstrip_Doc/JavaScript_Toolstirp_API_Doc.html#standardIcons';
            absoluteCEFPath = fullfile(matlabroot, 'cefclient', 'bin', 'win32', 'cefclient.exe');
            commandToExecute = sprintf('%s -url=%s --remote-debugging-port=9222', absoluteCEFPath, address);
            runtime = java.lang.Runtime.getRuntime();
            runtime.exec(commandToExecute);
        end
        
    end
    
    % ----------------------------------------------------------------------------
    % Standard icons from toolstrip icon library
    methods (Sealed, Static)
        function icon = ADD_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'ADD_16');
            icon = matlab.ui.internal.toolstrip.Icon('add_16',msg.getString());
        end
        function icon = ADD_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'ADD_24');
            icon = matlab.ui.internal.toolstrip.Icon('add_24',msg.getString());
        end
        function icon = ADD_ITEM_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'ADD_ITEM_12');
            icon = matlab.ui.internal.toolstrip.Icon('add_item_12',msg.getString());
        end
        function icon = BACK_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'BACK_16');
            icon = matlab.ui.internal.toolstrip.Icon('back_16',msg.getString());
        end
        function icon = BACK_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'BACK_24');
            icon = matlab.ui.internal.toolstrip.Icon('back_24',msg.getString());
        end
        function icon = CLEAR_ALL_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CLEAR_ALL_12');
            icon = matlab.ui.internal.toolstrip.Icon('clear_all_12',msg.getString());
        end
        function icon = CLOSE_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CLOSE_16');
            icon = matlab.ui.internal.toolstrip.Icon('close_16',msg.getString());
        end
        function icon = CLOSE_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CLOSE_24');
            icon = matlab.ui.internal.toolstrip.Icon('close_24',msg.getString());
        end
        function icon = CONFIRM_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CONFIRM_16');
            icon = matlab.ui.internal.toolstrip.Icon('confirm_16',msg.getString());
        end
        function icon = CONFIRM_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CONFIRM_24');
            icon = matlab.ui.internal.toolstrip.Icon('confirm_24',msg.getString());
        end
        function icon = COPY_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'COPY_16');
            icon = matlab.ui.internal.toolstrip.Icon('copy_16',msg.getString());
        end
        function icon = COPY_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'COPY_24');
            icon = matlab.ui.internal.toolstrip.Icon('copy_24',msg.getString());
        end
        function icon = CUT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CUT_16');
            icon = matlab.ui.internal.toolstrip.Icon('cut_16',msg.getString());
        end
        function icon = CUT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'CUT_24');
            icon = matlab.ui.internal.toolstrip.Icon('cut_24',msg.getString());
        end
        function icon = DELETE_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'DELETE_12');
            icon = matlab.ui.internal.toolstrip.Icon('delete_12',msg.getString());
        end
        function icon = EDIT_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'EDIT_12');
            icon = matlab.ui.internal.toolstrip.Icon('edit_12',msg.getString());
        end
        function icon = END_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'END_16');
            icon = matlab.ui.internal.toolstrip.Icon('end_16',msg.getString());
        end
        function icon = END_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'END_24');
            icon = matlab.ui.internal.toolstrip.Icon('end_24',msg.getString());
        end
        function icon = EXPORT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'EXPORT_16');
            icon = matlab.ui.internal.toolstrip.Icon('export_16',msg.getString());
        end
        function icon = EXPORT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'EXPORT_24');
            icon = matlab.ui.internal.toolstrip.Icon('export_24',msg.getString());
        end
        function icon = FORWARD_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'FORWARD_16');
            icon = matlab.ui.internal.toolstrip.Icon('forward_16',msg.getString());
        end
        function icon = FORWARD_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'FORWARD_24');
            icon = matlab.ui.internal.toolstrip.Icon('forward_24',msg.getString());
        end
        function icon = HELP_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'HELP_16');
            icon = matlab.ui.internal.toolstrip.Icon('help_16',msg.getString());
        end
        function icon = HELP_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'HELP_24');
            icon = matlab.ui.internal.toolstrip.Icon('help_24',msg.getString());
        end
        function icon = IMPORT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'IMPORT_16');
            icon = matlab.ui.internal.toolstrip.Icon('import_16',msg.getString());
        end
        function icon = IMPORT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'IMPORT_24');
            icon = matlab.ui.internal.toolstrip.Icon('import_24',msg.getString());
        end
        function icon = LAYOUT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'LAYOUT_16');
            icon = matlab.ui.internal.toolstrip.Icon('layout_16',msg.getString());
        end
        function icon = LAYOUT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'LAYOUT_24');
            icon = matlab.ui.internal.toolstrip.Icon('layout_24',msg.getString());
        end
        function icon = LEGEND_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'LEGEND_16');
            icon = matlab.ui.internal.toolstrip.Icon('legend_16',msg.getString());
        end
        function icon = LOCK_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'LOCK_12');
            icon = matlab.ui.internal.toolstrip.Icon('lock_12',msg.getString());
        end
        function icon = MATLAB_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'MATLAB_16');
            icon = matlab.ui.internal.toolstrip.Icon('matlab_16',msg.getString());
        end
        function icon = MATLAB_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'MATLAB_24');
            icon = matlab.ui.internal.toolstrip.Icon('matlab_24',msg.getString());
        end
        function icon = NEW_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'NEW_16');
            icon = matlab.ui.internal.toolstrip.Icon('new_16',msg.getString());
        end
        function icon = NEW_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'NEW_24');
            icon = matlab.ui.internal.toolstrip.Icon('new_24',msg.getString());
        end
        function icon = OPEN_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'OPEN_16');
            icon = matlab.ui.internal.toolstrip.Icon('open_16',msg.getString());
        end
        function icon = OPEN_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'OPEN_24');
            icon = matlab.ui.internal.toolstrip.Icon('open_24',msg.getString());
        end
        function icon = PAN_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PAN_16');
            icon = matlab.ui.internal.toolstrip.Icon('pan_16',msg.getString());
        end
        function icon = PASTE_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PASTE_16');
            icon = matlab.ui.internal.toolstrip.Icon('paste_16',msg.getString());
        end
        function icon = PASTE_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PASTE_24');
            icon = matlab.ui.internal.toolstrip.Icon('paste_24',msg.getString());
        end
        function icon = PAUSE_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PAUSE_16');
            icon = matlab.ui.internal.toolstrip.Icon('pause_16',msg.getString());
        end
        function icon = PAUSE_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PAUSE_24');
            icon = matlab.ui.internal.toolstrip.Icon('pause_24',msg.getString());
        end
        function icon = PLAY_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PLAY_16');
            icon = matlab.ui.internal.toolstrip.Icon('play_16',msg.getString());
        end
        function icon = PLAY_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PLAY_24');
            icon = matlab.ui.internal.toolstrip.Icon('play_24',msg.getString());
        end
        function icon = PRINT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PRINT_16');
            icon = matlab.ui.internal.toolstrip.Icon('print_16',msg.getString());
        end
        function icon = PRINT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PRINT_24');
            icon = matlab.ui.internal.toolstrip.Icon('print_24',msg.getString());
        end
        function icon = PROPERTIES_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PROPERTIES_16');
            icon = matlab.ui.internal.toolstrip.Icon('properties_16',msg.getString());
        end
        function icon = PROPERTIES_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'PROPERTIES_24');
            icon = matlab.ui.internal.toolstrip.Icon('properties_24',msg.getString());
        end
        function icon = REDO_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'REDO_16');
            icon = matlab.ui.internal.toolstrip.Icon('redo_16',msg.getString());
        end
        function icon = REDO_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'REDO_24');
            icon = matlab.ui.internal.toolstrip.Icon('redo_24',msg.getString());
        end
        function icon = REFRESH_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'REFRESH_16');
            icon = matlab.ui.internal.toolstrip.Icon('refresh_16',msg.getString());
        end
        function icon = REFRESH_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'REFRESH_24');
            icon = matlab.ui.internal.toolstrip.Icon('refresh_24',msg.getString());
        end
        function icon = REMOVE_ITEM_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'REMOVE_ITEM_12');
            icon = matlab.ui.internal.toolstrip.Icon('remove_item_12',msg.getString());
        end
        function icon = RUN_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'RUN_16');
            icon = matlab.ui.internal.toolstrip.Icon('run_16',msg.getString());
        end
        function icon = RUN_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'RUN_24');
            icon = matlab.ui.internal.toolstrip.Icon('run_24',msg.getString());
        end
        function icon = SAVE_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_16');
            icon = matlab.ui.internal.toolstrip.Icon('save_16',msg.getString());
        end
        function icon = SAVE_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_24');
            icon = matlab.ui.internal.toolstrip.Icon('save_24',msg.getString());
        end
        function icon = SAVE_ALL_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_ALL_16');
            icon = matlab.ui.internal.toolstrip.Icon('save_all_16',msg.getString());
        end
        function icon = SAVE_ALL_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_ALL_24');
            icon = matlab.ui.internal.toolstrip.Icon('save_all_24',msg.getString());
        end
        function icon = SAVE_AS_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_AS_16');
            icon = matlab.ui.internal.toolstrip.Icon('save_as_16',msg.getString());
        end
        function icon = SAVE_AS_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_AS_24');
            icon = matlab.ui.internal.toolstrip.Icon('save_as_24',msg.getString());
        end
        function icon = SAVE_DIRTY_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_DIRTY_16');
            icon = matlab.ui.internal.toolstrip.Icon('save_dirty_16',msg.getString());
        end
        function icon = SAVE_DIRTY_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SAVE_DIRTY_24');
            icon = matlab.ui.internal.toolstrip.Icon('save_dirty_24',msg.getString());
        end
        function icon = SEARCH_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SEARCH_16');
            icon = matlab.ui.internal.toolstrip.Icon('search_16',msg.getString());
        end
        function icon = SEARCH_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SEARCH_24');
            icon = matlab.ui.internal.toolstrip.Icon('search_24',msg.getString());
        end
        function icon = SELECT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SELECT_16');
            icon = matlab.ui.internal.toolstrip.Icon('select_16',msg.getString());
        end
        function icon = SELECT_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SELECT_24');
            icon = matlab.ui.internal.toolstrip.Icon('select_24',msg.getString());
        end
        function icon = SETTINGS_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SETTINGS_16');
            icon = matlab.ui.internal.toolstrip.Icon('settings_16',msg.getString());
        end
        function icon = SETTINGS_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SETTINGS_24');
            icon = matlab.ui.internal.toolstrip.Icon('settings_24',msg.getString());
        end
        function icon = SIMULINK_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SIMULINK_16');
            icon = matlab.ui.internal.toolstrip.Icon('simulink_16',msg.getString());
        end
        function icon = SIMULINK_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'SIMULINK_24');
            icon = matlab.ui.internal.toolstrip.Icon('simulink_24',msg.getString());
        end
        function icon = STOP_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'STOP_16');
            icon = matlab.ui.internal.toolstrip.Icon('stop_16',msg.getString());
        end
        function icon = STOP_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'STOP_24');
            icon = matlab.ui.internal.toolstrip.Icon('stop_24',msg.getString());
        end
        function icon = TOOLS_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'TOOLS_16');
            icon = matlab.ui.internal.toolstrip.Icon('tools_16',msg.getString());
        end
        function icon = TOOLS_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'TOOLS_24');
            icon = matlab.ui.internal.toolstrip.Icon('tools_24',msg.getString());
        end
        function icon = UNDO_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'UNDO_16');
            icon = matlab.ui.internal.toolstrip.Icon('undo_16',msg.getString());
        end
        function icon = UNDO_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'UNDO_24');
            icon = matlab.ui.internal.toolstrip.Icon('undo_24',msg.getString());
        end
        function icon = UNLOCK_12
            msg = message('MATLAB:toolstrip:general:standardIcon', 'UNLOCK_12');
            icon = matlab.ui.internal.toolstrip.Icon('unlock_12',msg.getString());
        end
        function icon = UP_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'UP_16');
            icon = matlab.ui.internal.toolstrip.Icon('up_16',msg.getString());
        end
        function icon = UP_24
            msg = message('MATLAB:toolstrip:general:standardIcon', 'UP_24');
            icon = matlab.ui.internal.toolstrip.Icon('up_24',msg.getString());
        end
        % VIEW icon with width = 16 and height = 12 is to be discussed
        %function icon = VIEW_16
        %    msg = message('MATLAB:toolstrip:general:standardIcon', 'VIEW_16');
        %    icon = matlab.ui.internal.toolstrip.Icon('view_16x12',msg.getString());
        %end
        function icon = ZOOM_IN_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'ZOOM_IN_16');
            icon = matlab.ui.internal.toolstrip.Icon('zoom_in_16',msg.getString());
        end
        function icon = ZOOM_OUT_16
            msg = message('MATLAB:toolstrip:general:standardIcon', 'ZOOM_OUT_16');
            icon = matlab.ui.internal.toolstrip.Icon('zoom_out_16',msg.getString());
        end
        
    end
    
    methods (Hidden)
        
        function url = getBase64URL(this)
            info = imfinfo(this.ImageFile);
            type = info.Format;
            fid = fopen(this.ImageFile,'rb');
            bytes = fread(fid);
            fclose(fid);
            encoder = org.apache.commons.codec.binary.Base64;
            str = transpose(char(encoder.encode(bytes)));
            url = ['url(data:image/' type ';base64,' str ')'];
        end
        
        function iconclass = getIconClass(this)
            iconclass = this.ImageFile;
        end
        
        function value = isCSS(this)
            value = this.IsCSS;
        end

    end
    
end
