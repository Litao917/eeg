function updateVisibility(this)
%Helper method for uitab

%   Copyright 2004 The MathWorks, Inc.
tabgroup = get(this, 'Parent');
children = handle(findobj(get(tabgroup, 'Children'),'Type','uitab'));
index = find(children == this);
if (isempty(index))
    return;
end

this.OKToModifyVis = true;
if (index == get(tabgroup, 'SelectedIndex'))    
    this.Visible = 'on';      
else    
    this.Visible = 'off';
end
this.OKToModifyVis = false;