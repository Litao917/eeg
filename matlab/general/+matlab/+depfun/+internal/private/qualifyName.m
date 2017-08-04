function qName = qualifyName(pth)
% qualifyName Turn a path into a qualified name by changing /@ and /+ , then
% any remaining /s, into .
%
% TODO: Is regexprep faster?
    qName = strrep(pth, [filesep '@'], '.');
    qName = strrep(qName, [filesep '+'], '.');
    qName = strrep(qName, filesep, '.');

    % Finally chop off any leading + or @
    if qName(1) == '+' || qName(1) == '@'
        qName = qName(2:end);
    end
end