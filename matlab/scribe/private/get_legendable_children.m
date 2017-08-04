function ch=get_legendable_children(ax)
%GET_LEGENDABLE_CHILDREN Gets the children for a legend
%  CH=GET_LEGENDABLE_CHILDREN(AX,INCLUDE_IMAGES) returns the
%  legendable children for axes AX. If INCLUDE_IMAGES is true then
%  include images in the list of legendable children.

% Copyright 2004-2010 The MathWorks, Inc.

if ~graphicsversion(ax,'handlegraphics')
    try 
        ch = get_legendable_childrenHGUsingMATLABClasses(ax);
    catch me
        throw(me)
    end
    return
end
            
legkids = get(ax,'Children');

% Take plotyy axes into account:
if isappdata(double(ax),'graphicsPlotyyPeer')
    newAx = getappdata(double(ax),'graphicsPlotyyPeer');
    if ~isempty(newAx) && ishandle(newAx)
        newChil = get(newAx,'Children');
        % The children of the axes of interest (passed in) should
        % appear lower in the stack than those of its plotyy peer.
        % The child stack gets flipud at the end of this function in
        % order to return a list in creation order.
        if ~isempty(newChil)
            legkids = [newChil(:); legkids(:)];
        else
            legkids = legkids(:);
        end            
    end
end

legkids = expandLegendChildren(legkids);

goodkid = true(length(legkids),1);
% v6-style scatter uses a special mechanism for legend
scattergrouplist = []; 

for k=1:length(legkids)
    h = legkids(k);
  goodkid(k) = islegendable(h);
%   if graphicsversion(ax,'handlegraphics')
      if goodkid(k) && isappdata(h,'scattergroup')
        scattergroup = getappdata(h,'scattergroup');
        if any(scattergrouplist==scattergroup)
          goodkid(k) = false;
        else
          scattergrouplist(end+1) = scattergroup;
        end
      end
%   end
end

% We need to return a list of legendable children in creation order, but
% the axes 'Children' property returns a stack (reverse creation order).
% So we flip it.
ch = flipud(legkids(goodkid));
