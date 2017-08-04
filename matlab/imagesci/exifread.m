function output = exifread(imagefile)
%EXIFREAD will be removed in a future release. Please use IMFINFO instead.

%   OUTPUT = EXIFREAD(IMAGEFILE) reads the EXIF image metadata from
%   the file specified by the string IMAGEFILE. IMAGEFILE should be
%   a JPEG or TIFF image file.  OUTPUT is a structure containing
%   metadata values about the image or images in IMAGEFILE.  This
%   function returns all EXIF tags and does not process them in any
%   way. 
%
%   For more information on EXIF and the meaning of metadata
%   attributes, see <http://www.exif.org/>.
%  
%   See also IMREAD, IMFINFO

%   Copyright 2005-2013 The MathWorks, Inc.

warning(message('MATLAB:imagesci:exifread:deprecatedFunction'));

validateattributes(imagefile,{'char'},{'nonempty'},'','IMAGEFILE');

fid = fopen(imagefile);
if (fid == -1)
    error(message('MATLAB:imagesci:validate:fileOpen',imagefile))
else
    % Get the full path to the file if it isn't in the current directory.
    imagefile = fopen(fid);
    fclose(fid);
end


if isjpg(imagefile) 
    output = exif_info_jpeg(imagefile);
elseif istif(imagefile)
    output = exif_info_tiff(imagefile);
else
    error(message('MATLAB:imagesci:exifread:unsupportedFormat'));
end

% check whether we need to convert UserNote from unicode to native 
if isfield(output, 'UserComment')
    if length(output.UserComment)>8 
        if double(output.UserComment(1:8)) == hex2dec(['55' '4E' '49' '43' '4F' '44' '45' '63'])
            output.UserComment = unicode2native(output.UserComment(9:end));
        else
            output.UserComment = output.UserComment(9:end);
        end
    end
end

%--------------------------------------------------------------------------
function info = exif_info_jpeg(jpgfile)

info = [];

fid = fopen(jpgfile,'r','ieee-be');
c = onCleanup(@() fclose(fid));
fseek(fid,2,'bof');

[~,exif_offset] = imjpgbaselineinfo(fid);
if exif_offset == 0
    return
end

% Seek to the start of the TIFF header.  Six bytes past the start of the
% APP0 segment (4 bytes for 'Exif', two empty separator bytes).
fseek(fid,exif_offset,'bof');

fileinfo = read_tiff_header(fid);

[info, ifd1_offset] = read_ifd(fileinfo, fid);
if isempty(info);
    return;
end

% Merge any Exif sub IFD into the main IFD.
if isfield(info,'Exif')
    fseek(fid,fileinfo.tiff_header + info.Exif,'bof');
    e = read_ifd(fileinfo,fid);
    
    info = rmfield(info,'Exif');
    fnames = fieldnames(e);
    for j = 1:numel(fnames)
        info.(fnames{j}) = e.(fnames{j});
    end
end
% Incorporate the thumbnail if there is one.
if ifd1_offset == 0
    return;
end
if ifd1_offset > fileinfo.bytes
    warning(message('MATLAB:imagesci:exifread:thumbnailOffsetTooLarge'));
    return
end
    
fseek(fid,fileinfo.tiff_header + ifd1_offset,'bof');    

info_ifd1 = read_ifd(fileinfo,fid);
info.Thumbnail = info_ifd1;

%--------------------------------------------------------------------------
function info = exif_info_tiff(tfile)

fid = fopen(tfile);
c = onCleanup(@() fclose(fid));

fileinfo = read_tiff_header(fid);

[info, ifd1_offset] = read_ifd(fileinfo, fid);

% Incorporate the thumbnail if there is one.
if ifd1_offset == 0
    return
end


fseek(fid,ifd1_offset,'bof');
info_ifd1 = read_ifd(fileinfo,fid);
info.Thumbnail = info_ifd1;

%--------------------------------------------------------------------------
function [info, next_ifd] = read_ifd(fileinfo, fid)
% Reads the entire IFD data structure (number of entries, the entries 
% themselves, any hanging sub IFD, and any foll


% Define how many bytes correspond to which tiff tag types.  See 
% /usr/include/tiff.h
nbytespertype = [0, 1, 1, 2, 4, 8, 1, 1, 2, 4, 8, 4, 8, 4];

% define the precision string to use when reading the tag data.
prec = {'uint8=>uint8', ... % NOTYPE
    'uint8=>double',      ... % BYTE
    'uint8=>double',      ... % ASCII
    'uint16=>double',     ... % SHORT
    'uint32=>double',     ... % LONG
    'uint32=>double',     ... % RATIONAL
    'int8=>double',       ... % SBYTE
    'uint8=>double',      ... % UNDEFINED
    'int16=>double',      ... % SSHORT
    'int32=>double',      ... % SLONG
    'int32=>double',      ... % SRATIONAL
    'single=>float',      ... % FLOAT
    'double',             ... % DOUBLE
    'uint32=>double'};        % IFD
    
dir_location = ftell(fid);    
num_directory_entries = fread(fid,1,'uint16=>double',0,fileinfo.endianness);
if num_directory_entries == 0
    info = [];
    next_ifd = 0;
    return
end

for j = 1:num_directory_entries

    fseek(fid, dir_location + 2 + (j-1) * 12, 'bof');

    % 1st uint16 is the tag ID, 2nd uint16 is the datatype.
    x = fread(fid,2,'uint16=>uint16',0,fileinfo.endianness);
    tag_id = x(1); tifftype = x(2);
    tag_count = fread(fid,1,'uint32=>uint32',0,fileinfo.endianness);
    
    if tifftype == 5 || tifftype == 10
        % For RATIONAL and SRATIONAL, we need to read a numerator and
        % denominator.
        tag_count = tag_count * 2;
    end
    
    % If the number of elements to read exceeds 4, we have to seek to that
    % file position to read the actual tag payload.
    nelts = nbytespertype(tifftype+1) * tag_count;
    if nelts > 4
        offset = fread(fid,1,'uint32=>uint32',0,fileinfo.endianness);
        cpos = ftell(fid);
        fseek(fid,fileinfo.tiff_header+offset,'bof');
        payload = fread(fid,tag_count,prec{tifftype+1},0,fileinfo.endianness);
        fseek(fid,cpos,'bof');
    else
        payload = fread(fid,tag_count,prec{tifftype+1},0,fileinfo.endianness);
    end
    
    % If the data is empty and NOT char (TIFF_ASCII_TYPE==2) skip it.
    if isempty(payload) && (tifftype ~= 2)
        warning(message('MATLAB:imagesci:exifread:zeroEntryCount',tag_id));
        continue;
    end

    [key,value] = process_tag(fileinfo,fid,tag_id,tifftype,tag_count,payload);
    if isempty(key)
        % Skip any unknown key.
        continue
    end

    info.(key) = value;

end


next_ifd = fread(fid,1,'uint32=>uint32',0,fileinfo.endianness);

%--------------------------------------------------------------------------
function info = read_tiff_header(fid)

% Get the general filesystem information.
info = dir(fopen(fid));

% Need to track the location of the TIFF header in order to handle any tags
% that do not fit into 4 bytes.
info.tiff_header = ftell(fid);

% read in the byte order of the TIFF header
byte_order = fread(fid,1,'uint16=>uint16');

if byte_order == 19789  % 19789 dec ==> 0x4D4D ==> "MM" ==> big endian
    info.endianness = 'ieee-be';
else % ==> 0x4949 ==> "II" ==> little endian
    info.endianness = 'ieee-le';
end

% 3rd and 4th bytes should be the version.  Should be 42 for classic tiff.
info.version = fread(fid,1,'uint16=>uint16',0,info.endianness);


% bytes 5-8 are the offset to first IDF.  Seek to that position.
ifd_offset = fread(fid,1,'uint32=>uint32',0,info.endianness);

% If the offset was eight, then just reading the TIFF header correctly positioned
% us to IFD0, so no action is necessary.  Otherwise, must advance the file 
% pointer accordingly.
fseek(fid, info.tiff_header + ifd_offset, 'bof' );

%---------------------------------------------------------------------------
function [key,value] = process_tag(fileinfo,fid,tag_id,tifftype,tag_count,payload)

key = [];
value = [];

keyset = {256, 257, 258, 259, 262, 270, 271, 272, 273, 274, 277, 278, 279, ...
    282, 283, 284, 296, 301, 305, 306, 315, 318, 319, 513, 514, 529, ...
    530, 531, 532, 4097, 4098, ...
    33421, 33423, 33432, 33434, 33437, 33723, ...
    34665, 34675, 34850, 34852, 34855, 34856, ...
    36864, 36867,36868,37121, ...  
    37122, 37377, 37378, 37379, 37380, 37381, 37382, 37383, 37384, ...
    37385, 37386, 37396,  ...
    37510, 37520, 35721, 37522, ...
    40960, 40961, 40962, 40963, 40964, ...
    41483, 41484, 41486, 41487, 41488, 41492, 41493, 41495,  ...
    41728, 41729, 41730, 41985, 41986,  41987, 41988, ...
    41989, 41990, 41991, 41992,  41993, 41994, 41995, 41996, 42016};

values = {'ImageWidth','ImageLength','BitsPerSample','Compression', ...
    'PhotometricInterpretation', 'ImageDescription', 'Make','Model', ...
    'StripOffsets','Orientation', 'SamplesPerPixel', 'RowsPerStrip', ...
    'StripByteCounts', 'XResolution','YResolution', ...
    'PlanarConfiguration', 'ResolutionUnit', 'TransferFunction', ...
    'Software', 'DateTime', 'Artist', 'WhitePoint', ...
    'PrimaryChromaticities', 'JPEGInterchangeFormat', ...
    'JPEGInterchangeFormatLength', 'YCbCrCoefficients', ...
    'YCbCrSubsampling', 'YCbCrPositioning', 'ReferenceBlackWhite', ...
    'RelatedImageWidth', 'RelatedImageLength', ...
    'CFARepeatPatternDim', 'BatteryLevel', 'Copyright', 'ExposureTime', ...
    'FNumber', 'IPTC/NAA', 'Exif', 'InterColorProfile', ...
    'ExposureProgram', 'SpectralSensitivity', 'ISOSpeedRatings','OECF', ...   
    'ExifVersion','DateTimeOriginal','DateTimeDigitized',...
    'ComponentsConfiguration','CompressedBitsPerPixel', ...    
    'ShutterSpeedValue', 'ApertureValue', 'BrightnessValue', ...
    'ExposureBiasValue', 'MaxApertureValue', ...
    'SubjectDistance' 'MeteringMode', 'LightSource', 'Flash', ...
    'FocalLength','SubjectArea', ...
    'UserComment','SubSecTime', ...
    'SubSecTimeOriginal','SubSecTimeDigitized', 'FlashpixVersion', ...
    'ColorSpace','PixelXDimension','PixelYDimension', ...
    'RelatedSoundFile','FlashEnergy', ...
    'SpatialFrequencyResponse',  'FocalPlaneXResolution', ...
    'FocalPlaneYResolution', 'FocalPlaneResolutionUnit', ...
    'SubjectLocation', 'ExposureIndex', 'SensingMethod', 'FileSource', ...
    'SceneType','CFAPattern','CustomRendered', 'ExposureMode', ...
    'WhiteBalance', 'DigitalZoomRatio','FocalLengthIn35mmFilm', ...
    'SceneCaptureType','GainControl','Contrast','Saturation','Sharpness', ...
    'DeviceSettingDescription','SubjectDistanceRange','ImageUniqueID'};
tags = containers.Map(keyset, values);


try
    key = tags(tag_id);
catch me
    if strcmp(me.identifier,'MATLAB:Containers:Map:NoKey')
        return
    else
        rethrown(me);
    end
end

switch(tifftype)
    case 2
        value = char(payload');
        
    case { 5, 10 }
        % RATIONAL and SRATIONAL
        % Divide to create the proper floating point value.
        value = payload(1) / payload(2);
    otherwise
        value = payload';
end

% And finally take care of any tag-specific processing.
switch(key)
        
    case {'ExifVersion', 'FlashpixVersion','UserComment'}
        % NOTYPE, but we interpret as char.
        value = char(value);
end

if ischar(value) && ~isempty(value) && (value(end) == char(0))
    % discard any trailing null char
    value = value(1:end-1);
end

% NaNs were treated as zero.
if isnan(value)
    value = 0;
end