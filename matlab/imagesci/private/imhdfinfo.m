function info = imhdfinfo(filename)
%IMHDFINFO Get information about images in an HDF file.
%   INFO = IMHDFINFO(FILENAME) returns information about the
%   8-bit and 24-bit raster image data sets in an HDF file.  INFO
%   is a structure array with the following fields:  Width,
%   Height, NumComponents, HasColormap, Tag, and Reference.  The
%   length of the structure array equals the number of image data
%   sets in the file.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2013 The MathWorks, Inc.

% Find full filename
fid = fopen(filename,'r','ieee-be');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

filename = fopen(fid);
d = dir(filename);
fclose(fid);

% Initialize the structure to fix the field order
info = initializeMetadataStruct('hdf');

info.FormatSignature = [];
info.NumComponents = [];
info.HasColormap = [];
info.Interlace = '';
info.Tag = [];
info.Reference = [];

DFTAG_RIG = 306;
DFREF_WILDCARD = 0;
FAIL = -1;

all.Filename = filename;
all.FileModDate = datestr(d.datenum);
all.FileSize = d.bytes;
all.Format = 'hdf';

if (~hdf('H','ishdf',filename))
    error(message('MATLAB:imagesci:imhdfinfo:notIsHDF', filename));
end

all.FormatSignature = [14 3 19 1];

hdf('DFR8','restart');
hdf('DF24','restart');

file_id = hdf('H', 'open', filename, 'read', 0);
if (file_id == FAIL)
    hdferror;
end

[major,minor,release,~,status] = hdf('H','getfileversion',file_id);
if (status == FAIL)
    hdf('H','close',file_id);
    hdferror;
end    

all.FormatVersion = sprintf('%d.%d.%d', major, minor, release);

%
% Find number of objects in file with the Raster Image Group tag
%
% numImages = hdf('H', 'number', file_id, DFTAG_RIG);
numImages = CountImages(file_id);
if (numImages == 0)
    hdf('H', 'close', file_id);    
    error(message('MATLAB:imagesci:imhdfinfo:noImages'));
end

%
% Grow the INFO structure array
%
info(numImages).Format = 'hdf';

%
% Find the reference numbers for all the raster image groups
%
for k = 1:numImages
    if (k == 1)
        h_id = hdf('H', 'startread', file_id, DFTAG_RIG, DFREF_WILDCARD);
        status = h_id;
    else
        status = hdf('H', 'nextread', h_id, DFTAG_RIG, DFREF_WILDCARD, ...
                'current');
    end
    if (status == FAIL)
        hdf('H','endaccess',h_id);
        hdf('H','close',file_id);
        hdferror;
    end
    [~, ~, ref, ~, ~, ~, ~, ~, status] = ...
            hdf('H', 'inquire', h_id);

    if (status == FAIL)
        hdf('H','close',file_id);
        hdferror;
    end
    
    info(k).Reference = ref;
    info(k).NumComponents = numcomp(file_id, ref);
    
end    
hdf('H','endaccess',h_id);
hdf('H','close',file_id);

%
% Use the DFR8 and DF24 interfaces to get the rest of the information
%
for k = 1:numImages
    info(k).Format = 'hdf';
    ref = info(k).Reference;
    
    if (info(k).NumComponents == 1)
        hdf('DFR8','readref',filename,ref);
        [w8,h8,hasmap] = hdf('DFR8', 'getdims', filename);
        info(k).Width = w8;
        info(k).Height = h8;
        info(k).BitDepth = 8;
        info(k).HasColormap = hasmap;
        if (info(k).HasColormap)
            info(k).ColorType = 'indexed';
        else
            info(k).ColorType = 'grayscale';
        end
        info(k).Tag = DFTAG_RIG;
        
    elseif (info(k).NumComponents == 3)
        hdf('DF24','readref',filename,ref);
        [w24,h24,il] = hdf('DF24', 'getdims', filename);
        info(k).Width = w24;
        info(k).Height = h24;
        info(k).HasColormap = 0;
        info(k).BitDepth = 24;
        info(k).ColorType = 'truecolor';
        info(k).Interlace = il;
        info(k).Tag = DFTAG_RIG;
        
    else
        error(message('MATLAB:imagesci:imhdfinfo:invalidComponentSize'));
    end
    
end

% Fill in the individual image info structures with the fields
% that apply to all images.
fieldNames = fieldnames(all);
for k = 1:length(info)
    for p = 1:length(fieldNames)
        field = fieldNames{p};
        info(k).(field) = all.(field);
    end
end

%%%
%%% Function hdferror
%%%
function hdferror()
%HDFERROR Generate error with the current HDF error string.

error(message('MATLAB:imagesci:imhdfinfo:hdferror', hdf( 'HE', 'string', hdf( 'HE', 'value', 1 ) )));


%%%
%%% Function numcomp
%%%
function num = numcomp(file_id, ref)
%NUMCOMP Number of components in raster image group

FAIL = -1;
DFTAG_RIG = 306;
DFTAG_ID = 300;

access_id = hdf('H', 'startread', file_id, DFTAG_RIG, ref);
if (access_id == FAIL)
    num = [];
    return;
end

memberList = hdf('H', 'read', access_id, 0);
hdf('H', 'endaccess', access_id);

memberList = Uint16Decode(memberList);
memberTags = memberList(1:2:end);
memberRefs = memberList(2:2:end);
idx = find(memberTags == DFTAG_ID);
if (isempty(idx))
    num = [];
    return;
else
    idx = idx(1);
end

access_id = hdf('H', 'startread', file_id, DFTAG_ID, memberRefs(idx));
if (access_id == FAIL)
    num = [];
    return;
end
memberList = hdf('H', 'read', access_id, 14);
hdf('H', 'endaccess', access_id);
if (length(memberList) < 14)
    num = [];
    return;
end
num = Uint16Decode(memberList(13:14));


%%%
%%% Uint16Decode --- turn uint8 input into uint16 integers
%%%
function out = Uint16Decode(in)

msb = double(in(1:2:end));
lsb = double(in(2:2:end));

out = bitshift(msb,8) + lsb;

%%%
%%% CountImages --- count number of Raster Image Groups in file
%%%
function numImages = CountImages(file_id)

DFTAG_RIG = 306;
DFREF_WILDCARD = 0;

numImages = 0;
h_id = hdf('H','startread', file_id, DFTAG_RIG, DFREF_WILDCARD);
if (h_id > 0)
    status = 0;
else
    status = -1;
end

while (status == 0)
    numImages = numImages + 1;
    status = hdf('H','nextread',h_id,DFTAG_RIG, DFREF_WILDCARD,'current');
end
hdf('H','endaccess',h_id);

