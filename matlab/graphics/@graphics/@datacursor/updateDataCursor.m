function updateDataCursor(hThis,hgObject,hDataCursor,target)

% This should be a static function, therefore, ignore "hThis"

%   Copyright 1984-2008 The MathWorks, Inc. 

% If hgObject is the same as the handle cached by hThis, then
% it is safe to access the cache. This check prevents bug: g202708
doCheckCache = isequal(handle(get(hThis,'Target')), ...
                       handle(hgObject));

% calling ismethod is a big performance hit, so we use the cache instead

hB = hggetbehavior(hgObject,'datacursor','-peek');
if ~isempty(hB) && ~isempty(hB.UpdateDataCursorFcn)
    hgfeval(hB.UpdateDataCursorFcn,hDataCursor,target);

%Slow: if ismethod(hgObject,'updateDataCursor') 
elseif doCheckCache && ...
   get(hDataCursor, 'TargetHasUpdateDataCursorMethod')
  
    try
       updateDataCursor(hgObject,hDataCursor,target);
    catch E %#ok<NASGU>
       % Something wrong with cache, do default
       hThis.default_updateDataCursor(hgObject,hDataCursor,target);
    end
    
% else do default
else
   hThis.default_updateDataCursor(hgObject,hDataCursor,target);
end


