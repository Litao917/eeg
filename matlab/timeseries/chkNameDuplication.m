function [newname, status] = chkNameDuplication(h,name,type)
%
% tstool utility function
% During rename operation, check if an object of the name specified already
% exists, ans an immediate child of parent h (such as tsparentnode or
% tscollectionNode object).
%
% "type": represents the node class, such as 'tsguis.tsnode'.

%   Copyright 2005-2012 The MathWorks, Inc.

newname = name;
status = true;


if localDoesNameExist(h,name,type)
    Namestr = getString(message('MATLAB:timeseries:NameAlreadyDefined', ...
        name));
elseif ~isempty(strfind(name,'/'))
    Namestr = getString(message('MATLAB:timeseries:SlashesNotAllowed'));
else
    return
end

tmpname = name;
while true
    answer = inputdlg(Namestr,getString(message('MATLAB:timeseries:EnterNewName')));
    % comparing the given new name with all the nodes in tstool
    %return if Cancel button was pressed
    if isempty(answer)
        status = false;
        return;
    end
    tmpname = strtrim(cell2mat(answer));
    if isempty(tmpname)
        Namestr = getString(message('MATLAB:timeseries:EmptyNamesNotAllowed'));
    else
        tmpname = strtrim(cell2mat(answer));
        %node = h.getChildren('Label',tmpname);
        if localDoesNameExist(h,tmpname,type)
            Namestr = getString(message('MATLAB:timeseries:NameAlreadyDefined',tmpname));
            continue;
        elseif ~isempty(strfind(tmpname,'/'))
            Namestr = getString(message('MATLAB:timeseries:SlashesNotAllowed'));
            continue;
        else
            newname = tmpname;
            break;
        end %if ~isempty(node)
    end %if isempty(answer)
end %while


%--------------------------------------------------------------------------
function Flag = localDoesNameExist(h,name,type)

nodes = h.getChildren('Label',name);
Flag = false;
if ~isempty(nodes)
    for k = 1:length(nodes)
        if strcmp(class(nodes(k)),type)
            Flag = true;
            break;
        end
    end
end