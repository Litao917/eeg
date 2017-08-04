function [pj, devices, options] = inputcheck( pj, varargin )
%INPUTCHECK Method to validate input arguments to PRINT.
%   Parses input arguments, updates state of PrintJob object accordingly.
%   Returns PrintJob object and cell-arrays for the lists of devices and
%   options that can legally be passed to PRINT.
%   Will error out if bad arguments are found.
%
%   Ex:
%      [pj, dev, opt] = INPUTCHECK( pj, ... );
%
%   See also PRINT, TABLE, VALIDATE.

%   Copyright 1984-2013 The MathWorks, Inc.

options = printtables(pj); % first find out what options are valid
deviceToCheck = ''; % placeholder for device/format caller wants to create; 

[handles,  simWindowName] = checkArgsForHandleToPrint(false, varargin{:});
if ~isempty(handles) 
    pj.Handles = [pj.Handles handles];
end
if pj.UseOriginalHGPrinting
    pj.SimWindowName = simWindowName;
end

for i = 1 : length(varargin)
    cur_arg = varargin{i};

    if isempty( cur_arg )
        %silly thing to do, ignore it

    elseif ~ischar( cur_arg ) 
        % Non-string argument better be a handle of a Figure or model. Dealt with in checkArgsForHandlesToPrint

    elseif (cur_arg(1) ~= '-')
        % Filename, can only have one!
        if isempty( pj.FileName )
            pj.FileName = cur_arg;
        else
            error(message('MATLAB:print:MultipleInputFiles', pj.FileName, cur_arg));
        end

    else
        switch( cur_arg(2) )

            case 'd'

                % delay processing of device until we know what
                % figure/system we are working with 
                % Device name
                if ~isempty(deviceToCheck) 
                   error(message('MATLAB:print:MultipleInputDeviceNames', deviceToCheck, cur_arg));
                end
                deviceToCheck = cur_arg; 

            case 'f' 
                % Handle Graphics figure handle dealt with in checkArgsForHandlesToPrint

            case 's' 
                % Simulink system name handled in checkArgsForHandlesToPrint

            case 'P'
                % Printer name - Windows and Unix
                pj.PrinterName = cur_arg(3:end);

                % check for empty name
                if(isempty(pj.PrinterName))
                    error(message('MATLAB:print:InvalidPrinterName'));
                end
                
                % Check for non-installed UNC path's on Windows systems and
                % warn users's that this functionality will be removed in
                % future versions. g611254
                if pj.UseOriginalHGPrinting && ...
                        ispc && ...
                        ~isempty(regexp(pj.PrinterName,'^\\\\.*?\\.*$','once')) && ...
                        ~queryPrintServices('validate', pj.PrinterName)
                    warning(message('MATLAB:print:UNCPrinterNotFoundWarning', pj.PrinterName));
                end
                
            otherwise
                %
                % Verify a given option is supported.
                % At this point we now it is a string that starts with -
                %
                opIndex = LocalCheckOption( cur_arg, options );

                %Some options are used in HARDCOPY, others used only in MATLAB before or after.
                %This switch must be kept up to date with options table and code i HARDCOPY.
                switch options{opIndex}

                    case 'loose'
                        pj.PostScriptTightBBox = 0;

                    case 'tiff'
                        pj.PostScriptPreview = pj.TiffPreview;

                    case 'append'
                        pj.PostScriptAppend = 1;

                    case 'adobecset'
                        pj.PostScriptLatin1 = 0;
                        if pj.UseOriginalHGPrinting
                            warning(message('MATLAB:print:DeprecatedOptionAdobecset'));
                        else
                            error(message('MATLAB:print:DeprecatedOptionAdobecsetRemoved'));
                        end

                    case 'cmyk'
                        pj.PostScriptCMYK = 1;
                        pj.PostScriptLatin1 = 0;

                    case 'r'
                        %Need number following -r for resolution
                        pj.DPI = round(sscanf( cur_arg, '-r%g' ));
                        if isempty(pj.DPI) || isnan(pj.DPI) || isinf(pj.DPI) || pj.DPI < 0
                            error(message('MATLAB:print:InvalidParamResolution'))
                        end

                    case 'noui'
                        pj.PrintUI = 0;
                        pj.nouiOption = 1;

                    case 'painters'
                        pj.Renderer = 'painters';
                        pj.rendererOption = 1;

                    case 'zbuffer'
                        if pj.XTerminalMode
                            warning(message('MATLAB:prnRenderer:zbuffer'))
                        else
                            pj.Renderer = 'zbuffer';
                            pj.rendererOption = 1;
                        end

                    case 'opengl'
                        if pj.UseOriginalHGPrinting
                            allowOpenGL = ~pj.XTerminalMode;
                        else
                            allowOpenGL = opengl('info');
                        end
                        if ~allowOpenGL
                            warning(message('MATLAB:prnRenderer:opengl'))
                        else
                            pj.Renderer = 'opengl';
                            pj.rendererOption = 1;
                        end

                    case 'tileall'
                        pj.TiledPrint = 1;

                    case 'printframes'
                        % no need to doc this one on print. This option is internally used by
                        % simprintdlg.
                        pj.FramePrint = 1;
                        
                    case 'numcopies'
                        % Used internally by simprintdlg2
                        pj.NumCopies = sscanf(cur_arg,'-numcopies%d');
                        
                    case 'pages'
                        [ a, count ] = sscanf(cur_arg, '-pages[ %d %d ]');
                        if (count ~= 2) || (a(1) < 1) || (a(2) > 9999) || (a(1) > a(2))
                            warning(message('MATLAB:print:InvalidParamPages'))
                        else
                            pj.FromPage = a(1);
                            pj.ToPage = a(2);
                        end

                    case 'DEBUG'
                        pj.DebugMode = 1;

                    case 'v'
                        %This is really just a PC option, but it would have gotten flagged earlier.
                        pj.Verbose = 1;

                    case 'RGBImage'
                        %reserved for future use
                        pj.RGBImage = 1;
                        pj.DriverClass = 'IM';
                        pj.DriverColor = 1;

                    case 'clipboard'
                        %reserved for future use
                        pj.ClipboardOption = 1;

                    otherwise
                        error(message('MATLAB:print:UnrecognizedOption', cur_arg))

                end %switch option
        end %switch cur_arg
    end % if isempty
end %for loop

% now check device/format to see if it's valid
% we already got options earlier - don't overwrite them here
% we also don't care about the descriptions here
[ ~, devices, extensions, classes, colorDevs, destinations, ~, clipsupport ] = printtables(pj);

% Call LocalCheckForDeprecation earlier as per g852505
if ~pj.UseOriginalHGPrinting && ~isempty(deviceToCheck) && ~isSLorSF(pj) 
    if length(deviceToCheck)>2
        pj.Driver = deviceToCheck(3:end);
        LocalCheckForDeprecation(pj); % warn if using deprecated device
    end
end
[ pj, devIndex ] = LocalCheckDevice( pj, deviceToCheck, devices );
   
   % caller specified a device
if ~isempty(deviceToCheck)
   if devIndex == 0 
      %we couldn't find requested device 
      %Will echo out possible values or error out depending on input to PRINT
      pj.Driver = '-d';
      return
   end
   % found requested device, set printjob fields appropriately
   pj.DriverExt       = extensions{ devIndex };
   pj.DriverClass     = classes{ devIndex };
   pj.DriverColor     = strcmp( 'C', colorDevs{ devIndex } );
   pj.DriverColorSet  = 1;
   pj.DriverExport    = strcmp( 'X', destinations{ devIndex } );
   pj.DriverClipboard = clipsupport{devIndex};

   % We don't want to check for deprecation if we are using new SL/SF editor
   % pipeline. Any format support depends on what the new editor supports.
   % So skip this deprecation check.
   % -sramaswa
   if ~isSLorSF(pj)
      LocalCheckForDeprecation(pj); % warn if using deprecated device
   end
end

% warn if caller requested zbuffer & use opengl instead
if ~pj.UseOriginalHGPrinting && pj.rendererOption && strcmpi(pj.Renderer, 'zbuffer')
    pj.Renderer = 'opengl';
    warning(message('MATLAB:print:DeprecateZbuffer'));
end

end



%%%%
%%%% LocalCheckDevice
%%%%
function [ pj, devIndex ] = LocalCheckDevice( pj, cur_arg, devices )
%LocalCheckDevice Verify device given is supported, and only one is given.
%    device proper starts after '-d', if only '-d'
%    we will later echo out possible choices

%We already know first two characters are '-d'
if ( length(cur_arg) > 2 )

    %Is there one unique match?
    devIndex = find(strcmp( cur_arg(3:end), devices));
    if length(devIndex) == 1
        pj.Driver = cur_arg(3:end);

    else
        %Is there one partial match, i.e. -dtiffn[ocompression]
        %todo how to do partial matches with strcmp?
        devIndex = strmatch( cur_arg(3:end), devices ); 
        if length( devIndex ) == 1
            %Save the full name
            pj.Driver = devices{devIndex};

        elseif length( devIndex ) > 1
            error(message('MATLAB:print:NonUniqueDeviceOption', cur_arg))

        else
            % A special case, -djpegnn, where nn == quality level
            if strncmp( cur_arg, '-djpeg', 6 )
                if isempty( str2num(cur_arg(7:end)) ) %#ok
                    error(message('MATLAB:print:JPEGQualityLevel'));
                end
                %We want to keep quality level in device name.
                pj.Driver = cur_arg(3:end);
                devIndex = find(strcmp('jpeg',devices));
            else
                error(message('MATLAB:print:InvalidDeviceOption', cur_arg));
            end
        end
    end
else
    devIndex = 0;
end
%EOFunction LocalCheckDevice
end

%%%%
%%%% LocalCheckOption
%%%%
function opIndex = LocalCheckOption( op, options )
%LocalCheckOption Verify option given is supported, and only one is given.
%    Option proper starts after '-'. Returns index into options cell array or errors.

%We already know first character is '-'
if ( size(op, 2) > 1 )

    option = op(2:end);

    %Is there one unique match?
    opIndex = find(strcmp( option, options));
    
    if length(opIndex) ~= 1

        %Is there one partial match, i.e. -adobe
        opIndex = find(strcmp( option, options ));

        if isempty(opIndex)

            %Special case 1
            if strcmp( option, 'epsi' )
                %This was a grandfathered preview format. Tell the user s/he is
                %using something no longer supported and give him/her the new
                %and improved preview, TIFF.
                if pj.UseOriginalHGPrinting
                    warning(message('MATLAB:print:UnsupportedFormatEPSI'))
                else
                    error(message('MATLAB:print:UnsupportedFormatEPSIError'))
                end
                opIndex = find(strcmp( 'tiff', options));

                %Special case 2
            elseif option(1) == 'r'
                %Resolution switch. As given by user will have a number after it
                %If there is nothing after it, it means to use screen resolution
                %That case is caught in the first strmatch.
                opIndex = find(strcmp( 'r', options));
                
            elseif strncmp(option, 'pages[', 6)
                %Pages range. User will supply the from/to page after the switch
                opIndex = find(strcmp( 'pages', options));

            %Undocumented, and only for simulink
            elseif strncmp(option, 'numcopies', 9)
                %Number of copies.
                opIndex = find(strcmp( 'numcopies', options));
            
            else
                error(message('MATLAB:print:UnrecognizedOption', op))
            end

        elseif length(opIndex) > 1
            error(message('MATLAB:print:NonUniqueOption', op))
        end
    end
else
    error(message('MATLAB:print:ExpectedOption'))
end
%EOFunction LocalCheckOption
end

%
% LocalCheckForDeprecation - warn if using one of devices being deprecated
%
function LocalCheckForDeprecation(pj)
msgID = '';
msgText = '';
deviceToCheck = pj.Driver;

% Get deprecated device list
[ ~, ~, ~, ~, depDevices, depDestinations, ~ ] = getDeprecatedDeviceList();
depIndex = find(strcmp(depDevices, deviceToCheck));
if isempty(depIndex)
    return;
end
depDest = depDestinations(depIndex);
if isempty(depDest)
    depDest = '';
end

if strcmpi(deviceToCheck, 'ill')
    % Native illustrator support will be removed
    msgID = 'MATLAB:print:Illustrator:DeprecatedDevice';
    if pj.UseOriginalHGPrinting
        msgText = getString(message('MATLAB:uistring:inputcheck:ThedillPrintDeviceWillBeRemovedInAFutureRelease'));
    else
        msgText = getString(message('MATLAB:uistring:inputcheck:ThedillPrintDeviceHasBeenRemoved'));
    end
elseif strcmpi(deviceToCheck, 'mfile')
    % MFile Code Generation Option Removed
    msgID = 'MATLAB:print:DeprecatedMATLABCodeGenerationOption';
    if pj.UseOriginalHGPrinting
        msgText = getString(message('MATLAB:printdmfile:DeprecatedMATLABCodeGenerationOption'));
    else
        msgText = getString(message('MATLAB:print:DeprecatedMATLABCodeGenerationOption'));
    end
elseif strcmp('P', depDest)
    % some older printer devices are being deprecated
    msgID = 'MATLAB:Print:Deprecate:PrinterFormat';
    if pj.UseOriginalHGPrinting
        msgText = sprintf('%s',getString(message('MATLAB:uistring:inputcheck:ThePrintDeviceWillBeRemovedInAFutureRelease', ...
                             deviceToCheck)));
    else
        msgText = sprintf('%s',getString(message('MATLAB:uistring:inputcheck:ThePrintDeviceHasBeenRemoved', ...
                           deviceToCheck)));
    end
elseif strcmp('X', depDest)
    msgID = 'MATLAB:Print:Deprecate:GraphicFormat';
    if pj.UseOriginalHGPrinting
        msgText = sprintf( getString(message('MATLAB:uistring:inputcheck:TheGraphicExportFormatWillBeRemovedInAFutureRelease', ...
                              deviceToCheck)));
    else
        msgText = sprintf( getString(message('MATLAB:uistring:inputcheck:TheGraphicExportFormatHasBeenRemoved', ...
                            deviceToCheck)));
    end
elseif strcmpi('setup',deviceToCheck)
    msgID = 'MATLAB:Print:DSetupOptionRemoved';
    if pj.UseOriginalHGPrinting
        msgText = sprintf( getString(message('MATLAB:print:DSetupOptionDeprecation')));
    else
        msgText = sprintf( getString(message('MATLAB:print:DSetupOptionRemoved')));
    end
end

if ~isempty(msgID)
    if pj.UseOriginalHGPrinting
        warning(msgID, msgText);
    else
        error(msgID, msgText);
    end
end

%EOFunction LocalCheckForDeprecation
end

% LocalWords:  pj dev prn adobecset cmyk noui zbuffer tileall printframes IM
% LocalWords:  GL EO dtiffn ocompression djpegnn nn djpeg jpeg Qlvl epsi opn
% LocalWords:  obsoleteprintdevices depsc hpgl pkm pkmraw tifflzw
