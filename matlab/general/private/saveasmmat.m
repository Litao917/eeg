function saveasmmat( h, name )
%SAVEASM Save Figure as a MATLAB file and MAT-file for property values

%   Copyright 1984-2007 The MathWorks, Inc. 

% remove ext from filename so appropriate MATLAB file / MAT-file pairs get generated
[path, name, ext] = fileparts(name);

if ~isempty(find(name == '.'))
    error(message('MATLAB:saveasmmat:InvalidFilename', filename));
end

hardcopy(h, '-dmfile', fullfile(path, name));
