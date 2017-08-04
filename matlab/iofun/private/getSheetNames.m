function sheets = getSheetNames(workbook_xml_rels, workbook_xml)
    % getSheetNames parses OpenXML to extract Worksheet names.
    %   sheets = getSheetNames(workbook_xml_rels, workbook_xml) parses the 
    %   Office Open XML code in the char array docProps to extract 
    %   Worksheet names into the cell array sheets.
    %
    %   See also xlsread, xlsfinfo
    
    % Copyright 2011-2013 The MathWorks, Inc.

    sheetIDs = regexp(workbook_xml_rels, ...
                 '<Relationship Id="rId(\d+?)" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/.+?.xml"/>', ...
                 'tokens' );
    sheetIDs = sort(str2double([sheetIDs{:}]));
    
    sheets = cell(1,length(sheetIDs));
    for i = 1:length(sheetIDs)
        match = regexp(workbook_xml, ...
                       ['<sheet name=".*(?<=<sheet name=")(?<sheetName>.+?)(?=" sheetId=".*" r:id="rId' num2str(sheetIDs(i)) '"/>)'], ...
                       'names' );
        sheets{i} = match.sheetName;
    end
    
end