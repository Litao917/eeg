function info = createStackInfo(stack)

% Copyright 2012 The MathWorks, Inc.

includeLinks = matlab.unittest.internal.diagnostics.shouldHyperLink();

cellOfStrings = cell(size(stack));
for idx = 1:length(stack)
    frame = stack(idx);
        
    % Handle the empty case
    if isempty(frame.file)
        cellOfStrings{idx} = sprintf('%s (%s)', ...
            getString(message('MATLAB:unittest:FailureDiagnosticsPlugin:In')), frame.name);
        continue
    end
    
    % Create readable string
    fileThenNameAtLine = sprintf('%s (%s) %s %d', frame.file, frame.name, ...
        getString(message('MATLAB:unittest:FailureDiagnosticsPlugin:At')), frame.line);
    isMFile = ~isempty(regexpi(frame.file,'\.m$','once')); 
    if includeLinks && isMFile;
        % Hyperlink the file
        cellOfStrings{idx} = sprintf('%s <a href="matlab: opentoline(%s,%d,1)">%s</a>', ...
            getString(message('MATLAB:unittest:FailureDiagnosticsPlugin:In')), ...
            frame.file, frame.line, fileThenNameAtLine);
        continue
    end
    
    % produce unhyperlinked file
    cellOfStrings{idx} = sprintf('%s %s', ...
        getString(message('MATLAB:unittest:FailureDiagnosticsPlugin:In')), fileThenNameAtLine);

end

info = sprintf('%s\n', cellOfStrings{:});

% Remove the last newline character.
if ~isempty(info)
    info(end) = [];
end

% LocalWords:  unhyperlinked
