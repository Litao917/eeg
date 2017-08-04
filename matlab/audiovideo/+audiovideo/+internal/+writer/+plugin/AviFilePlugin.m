classdef (Hidden) AviFilePlugin < audiovideo.internal.writer.plugin.IPlugin
    %AviFilePlugin Extension of the IPlugin class to write uncompressed AVI files.
    
    % Copyright 2009-2013 The MathWorks, Inc.
    
    properties
        ColorFormat = 'RGB24';
        ColorChannels = 3;
        BitsPerPixel = 24;
    end
    
    properties(Access=protected)
        FileName;
        CustomEventListener;
    end
        
    methods
        function obj = AviFilePlugin(fileName)
            %AviFilePlugin Construct a AviFilePlugin object.
            %
            %   OBJ = AviFilePlugin(FILENAME) constructs a AviFilePlugin
            %   object pointing to the file specified by FILENAME.  The file
            %   is not created until AviFilePlugin.open() is called.
            %
            %   See also AviFilePlugin/open, AviFilePlugin/close.
            
            obj = obj@audiovideo.internal.writer.plugin.IPlugin();
            
            % Handle the zero argument constructor.  This is needed, for
            % example, when constructing empty profile objects.
            if isempty(fileName)
                obj.Channel = [];
                return;
            end
            
            obj.FileName = fileName;
        end
        
        function set.FileName(obj, value)
            obj.FileName = value;
            
            % After setting the value, create the asyncio Channel object.
            % This is done here instead of in the constructor
            % so that the channel is initialized properly during load and
            % save
            obj.createChannel();
        end
        
        function open(obj, options)
            %OPEN Opens the channel for writing.
            %   AviFilePlugin objects must be open prior to calling
            %   writeVideoFrame.
                        
            assert(~isempty(obj.Channel), 'Channel must be set before opening the plugin');
            obj.open@audiovideo.internal.writer.plugin.IPlugin();
            
            try 
                obj.Channel.open(options);
            catch devErr
                obj.handleDeviceError(devErr.identifier, devErr.message);
            end
        end
        
        function writeVideoFrame(obj, data)
            %writeVideoFrame Write a single video frame to the channel.
            %   obj.writeVideoFrame(data) will write a single video frame
            %   to the channel.  Since the MATFilePlugin isn't actually a
            %   video plugin, MATFilePlugin/writeVideoFrame will accept any
            %   data in any format, which is useful for testing.
            
            assert(~isempty(obj.Channel), 'Channel must be set before writing to the plugin');
            assert(obj.Channel.isOpen(), 'Channel must be open before writing data.');
            assert(isnumeric(data) || isstruct(data), 'Data to write must be numeric or struct');
                        
            try
                obj.Channel.OutputStream.write(data);
            catch devErr
                obj.handleDeviceError(devErr.identifier, devErr.message);
            end
        end
        
        function [pluginName, mlConverterName, slConverterName, options] = ...
                                                getChannelInitOptions(obj)
            %GETCHANNELINITOPTIONS options for asyncio channel creation
            %   Setup options used in createChannel function.
            %   Subclasses can override this function to provide custom
            %   plugins and options
            pluginName = 'videoaviwriterplugin';
            [mlConverterName, slConverterName] = obj.getConverterName;
            options.OutputFileName = obj.FileName;
            options.FileFormat = obj.ColorFormat;
        end
        
        function [filterName, options] = getFilterInitOptions(obj)
            filterName = 'videotransformfilter';
            options.InputFrameType = 'RGB24PlanarColumn';
            if ~isempty(obj.Channel)
                options.OutputFrameType = obj.Channel.ExpectedFrameType;
            else
                options.OutputFrameType = '';
            end
        end
    end
    
    methods(Access=protected)
        
        function [mlErrorID, msgHoles] = deviceErrorToErrorID(obj, deviceErr, ~)
            %DEVICEERRORTOERRORID conversion from Device Error ID to MATLAB
            %Error ID
            %   Convert the Error ID generated by the Device Plugin to a
            %   MATLAB Error ID. Each plugin has knowledge about the
            %   specific errors that are thrown by the corresponding Device
            %   Plugin
            msgHoles = {};
            mlPrefix =  audiovideo.internal.writer.plugin.IPlugin.ErrorPrefix;
            switch(deviceErr)
                case 'aviPlugin:invalidFileName'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'invalidFileName');
                case 'aviPlugin:invalidFrameRate'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'invalidFrameRate');
                case 'aviPlugin:jpeginit'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'jpeginit');
                case 'aviPlugin:couldNotOpenFile'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'couldNotOpenFile');
                case 'aviPlugin:couldNotInitFile'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'couldNotInitFile');
                case 'aviPlugin:couldNotWriteFrame'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'couldNotWriteFrame');
                case 'aviPlugin:jpegcompress'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'jpegcompress');
                case 'aviPlugin:unexpectedError'
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'unexpectedErrorWithReason');
                    msgHoles = {deviceMsg};
                otherwise
                    mlErrorID = sprintf('%s:%s', mlPrefix, 'unexpectedError');
            end
        end
        
    end
end

