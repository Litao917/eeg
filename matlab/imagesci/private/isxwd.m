function tf = isxwd(filename)
%ISXWD Returns true for an XWD file.
%   TF = ISXWD(FILENAME)

%   Copyright 1984-2013 The MathWorks, Inc.

% XWD files can be big or little-endian.  Try it big-endian
% first.
fid = fopen(filename, 'r', 'ieee-be');  % BMP files are little-endian
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
sig = fread(fid, 3, 'uint32');
fclose(fid);
if (length(sig) < 3)
    tf = false;
else
    if (sig(2) == 7)
        tf = ((sig(1) >= 100) & (ismember(sig(3), [0 1 2])));
        
    elseif (sig(2) == byteswap(7))
        % 112 is 7 byte-reversed; maybe it's a little-endian XWD file.
        sig(1) = byteswap(sig(1));
        sig(3) = byteswap(sig(3));
        tf = ((sig(1) >= 100) & (ismember(sig(3), [0 1 2])));

    else
        tf = false;
    end
end


function out = byteswap(in)
%BYTESWAP Swap byte order for a number between 0 and 65535.
%   OUT = BYTESWAP(IN)

lowByte = bitand(in, 255);
highByte = bitshift(bitand(in, 65280), -8);
out = bitor(bitshift(lowByte, 8), highByte);

