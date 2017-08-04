function X = readbmpdata(info)
%READBMPDATA Read bitmap data
%   X = readbmpdata(INFO) reads image data from a BMP file.  INFO is a
%   structure returned by IMBMPINFO. X is a uint8 array that is 2-D for
%   1-bit, 4-bit, and 8-bit image data.  X is M-by-N-by-3 for 24-bit and
%   32-bit image data.  

%   Copyright 1984-2013 The MathWorks, Inc.


switch info.CompressionType
    
    case {'none', 'bitfields'}
        
        switch info.BitDepth
            case 1
                X = logical(bmpReadData1(info));
                
            case 4
                X = bmpReadData4(info);
                
            case 8
                X = bmpReadData8(info);
                
            case 16
                X = bmpReadData16(info);
                
            case 24
                X = bmpReadData24(info);
                
            case 32
                X = bmpReadData32(info);
                
        end
        
    case '8-bit RLE'
        X = bmpReadData8RLE(info);
        
    case '4-bit RLE'
        X = bmpReadData4RLE(info);
        
    otherwise
        error(message('MATLAB:imagesci:readbmpdata:unsupportedCompressionScheme', ...
            info.CompressionType));
                
end
        

%---------------------------------------------------------------------------
function X = bmpReadData8(info)
%%% bmpReadData8 --- read 8-bit bitmap data

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
paddedWidth = 4*ceil(info.Width/4);
numbytes = paddedWidth*abs(info.Height);

X = readFromFile(info, numbytes, 'ieee-le', '*uint8');

if info.Height>=0
  X = rot90(reshape(X, paddedWidth, info.Height));
else
  X = reshape(X, paddedWidth, abs(info.Height))';
end

if (paddedWidth ~= info.Width)
    X = X(:,1:info.Width);
end



%---------------------------------------------------------------------------
function X = bmpReadData8RLE(info)
%%% bmpReadData8RLE --- read 8-bit RLE-compressed bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
paddedWidth = 4*ceil(width/4);
numbytes = info.FileSize - info.ImageDataOffset;

inBuffer = readFromFile(info, numbytes, 'ieee-le', '*uint8');

X = bmpdrle(inBuffer, paddedWidth, abs(height), 'rle8');

if height>=0
  X = rot90(X);
else
  X = X';
end
if (paddedWidth ~= width)
    X = X(:,1:width);
end



%---------------------------------------------------------------------------
function X = bmpReadData4(info)
%%% bmpReadData4 --- read 4-bit bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
paddedWidth = 8*ceil(width/8);
numbytes = paddedWidth * abs(height) / 2; % evenly divides because of padding

XX = readFromFile(info, numbytes, 'ieee-le', '*uint8');

XX = reshape(XX, paddedWidth / 2, abs(height));

X = repmat(uint8(0), paddedWidth, abs(height));
X(1:2:end,:) = bitslice(XX,5,8);
X(2:2:end,:) = bitslice(XX,1,4);

if height>=0
  X = rot90(X);
else
  X = X';
end
if (paddedWidth ~= width)
    X = X(:,1:width);
end


%---------------------------------------------------------------------------
function X = bmpReadData4RLE(info)
%%% bmpReadData4RLE --- read 4-bit RLE-compressed bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
paddedWidth = 8*ceil(width/8);
numbytes = info.FileSize - info.ImageDataOffset;

inBuffer = readFromFile(info, numbytes, 'ieee-le', '*uint8');

if height>=0
  X = rot90(bmpdrle(inBuffer, paddedWidth, abs(height), 'rle4'));
else
  X = bmpdrle(inBuffer, paddedWidth, abs(height), 'rle4')';
end
if (paddedWidth ~= width)
    X = X(:,1:width);
end


%---------------------------------------------------------------------------
function X = readFromFile(info, numbytes, machfmt, precstr)

fid = fopen(info.Filename,'r',machfmt);
cfid = onCleanup( @() fclose(fid));
status = fseek(fid,info.ImageDataOffset,'bof');
if status==-1
  error(message('MATLAB:imagesci:readbmpdata:fseekError',ferror(fid)));
end
[X, count] = fread(fid,numbytes,precstr);
  
if (count ~= numbytes)
    warning(message('MATLAB:imagesci:readbmpdata:truncatedImageData'));
    % Fill in the missing values with zeros.
    X(numbytes) = 0;
end


%---------------------------------------------------------------------------
function X = bmpReadData1(info)
%%% bmpReadData1 --- read 1-bit bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
paddedWidth = 32*ceil(width/32);
numPixels = paddedWidth * abs(height);  % evenly divides because of padding
machfmt = 'ieee-be';  % 1-bit BMP data has big-endian byte ordering

X = readFromFile(info, numPixels, machfmt, '*ubit1');

X = reshape(X, paddedWidth, abs(height));

if height>=0
  X = rot90(X);
else
  X = X';
end

if (paddedWidth ~= width)
    X = X(:,1:width);
end



%---------------------------------------------------------------------------
function RGB = bmpReadData16(info)
%%% bmpReadData16 --- read 16-bit bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
scanlineLength = 2 * ceil(width/2);
numSamples = scanlineLength * abs(height);

X = readFromFile(info, numSamples, 'ieee-le', 'uint16=>uint16');

if (height >= 0)
  X = rot90(reshape(X, scanlineLength, abs(height)));
else
  X = reshape(X, scanlineLength, abs(height))';
end

if (scanlineLength ~= width)
    X = X(:, 1:width);
end

RGB(1:abs(height), 1:width, 1) = uint8(bitslice(X,11,15));
RGB(:,:,2) = uint8(bitslice(X,6,10));
RGB(:,:,3) = uint8(bitslice(X,1,5));

%Scale data for display
RGB = bitor(bitshift(RGB,3),bitshift(RGB,-2));

%---------------------------------------------------------------------------
function RGB = bmpReadData24(info)
%%% bmpReadData24 --- read 24-bit bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
scanlineLength = 4 * ceil((3 * width) / 4);
numSamples = scanlineLength * abs(height);

X = readFromFile(info, numSamples, 'ieee-le', 'uint8=>uint8');

if (height >= 0)
  X = rot90(reshape(X, scanlineLength, abs(height)));
else
  X = reshape(X, scanlineLength, abs(height))';
end

if (width ~= scanlineLength/3)
    X = X(:, 1:(3 * width));
end

RGB(1:abs(height), 1:width, 3) = X(:,1:3:end);
RGB(:, :, 2) = X(:,2:3:end);
RGB(:, :, 1) = X(:,3:3:end);


%---------------------------------------------------------------------------
function RGB = bmpReadData32(info)
%%% bmpReadData32 --- read 32-bit bitmap data

width = info.Width;
height = info.Height;

% NOTE: BMP files are stored so that scanlines use a multiple of 4 bytes.
scanlineLength = 4 * width;
numSamples = scanlineLength * abs(height);

X = readFromFile(info, numSamples, 'ieee-le', 'uint8=>uint8');

if (height >= 0)
  X = rot90(reshape(X, scanlineLength, abs(height)));
else
  X = reshape(X, scanlineLength, abs(height))';
end

RGB(1:abs(height), 1:width, 3) = X(:,1:4:end);
RGB(:, :, 2) = X(:,2:4:end);
RGB(:, :, 1) = X(:,3:4:end);
