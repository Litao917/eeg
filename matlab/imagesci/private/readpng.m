function [X,map,alpha] = readpng(filename, varargin)
%READPNG Read an image from a PNG file.
%   [X,MAP] = READPNG(FILENAME) reads the image from the
%   specified file.
%
%   [X,MAP] = READPNG(FILENAME,'BackgroundColor',BG) uses the
%   specified background color for compositing transparent
%   pixels.  By default, READPNG uses the background color
%   specified in the file, if present.  If not present, the
%   default is either the first colormap color or black.  If the
%   file contains an indexed image, BG must be an integer in the
%   range [1,P] where P is the colormap length.  If the file
%   contains a grayscale image, BG must be an integer in the
%   range [0,65535].  If the file contains an RGB image, BG must
%   be a 3-element vector whose values are in the range
%   [0,65535].
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2013 The MathWorks, Inc.

bg = parse_args(varargin{:});

if (isempty(bg) && (nargout >= 3))
    % User asked for alpha and didn't specify a background
    % color; in this case we don't perform the compositing.
    bg = 'none';
end

alpha = [];
try
    [X,map,oneRow3d] = pngreadc(filename, bg, false);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:png:libraryFailure')
        [X,map,oneRow3d] = pngreadc(filename, bg,true);
        warning(message('MATLAB:imagesci:png:tooManyIDATsData'));
    else
        rethrow(me);
    end
end
X = permute(X, ndims(X):-1:1);

if oneRow3d
    X = reshape(X,[1 size(X)]);
end

if (ismember(size(X,3), [2 4]))
    alpha = X(:,:,end);
    % Strip the alpha channel off of X.
    X = X(:,:,1:end-1);
end



%--------------------------------------------------------------------------
function bg = parse_args(param,value)

bg = [];
if nargin < 1
    return
end

% Process param/value pairs.  Only 'backgroundcolor' is recognized.
validateattributes(param,{'char'},{'nonempty'},'','BACKGROUNDCOLOR');
validatestring(param,{'backgroundcolor'});
bg = value;

return

