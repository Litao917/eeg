function h = getScribeMenuItems(fig)
% Returns the scribe-related menu items from the various menus present in
% the figure.

%   Copyright 2006 The MathWorks, Inc.

hinsertmenu = findall(allchild(fig), 'flat','Type','uimenu', 'Tag', 'figMenuInsert');
h = [findall(hinsertmenu, 'Tag', 'figMenuInsertAxes'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertEllipse'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertRectangle'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertTextbox'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertArrow2'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertArrow'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertLine'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertColorbar'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertLegend'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertTitle'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertXLabel'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertYLabel'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertZLabel'); ...
    findall(hinsertmenu, 'Tag', 'figMenuInsertLight')];