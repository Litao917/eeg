function leg_images = getLegendableImages(h)

% Returns an array of Images which should be viewed as legendable by the
% Plot Browser

%   Copyright 2009-2011 The MathWorks, Inc.

legkids = findobj(h,'-depth',1,'-property','Annotation','type','image');
I = false(size(legkids));
for k=1:length(legkids)
    hA = get(legkids(k),'Annotation');
    if (ishandle(hA) || (isobject(hA) && isvalid(hA))) && ...
            hasbehavior(legkids(k),'legend')
        hL = hA.LegendInformation;
        if ishandle(hL) || isobject(hL)
            I(k) = ~strcmpi(hL.IconDisplayStyle,'off');
        end
    else
        I(k) = true;
    end
end
leg_images = legkids(I);