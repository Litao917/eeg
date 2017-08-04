function tf = existClass(nm)    
% Does meta.class.fromName know about it?
    tf = false;
    metadata = meta.class.fromName(nm);
    if ~isempty(metadata)
        tf = true;
    elseif matlab.depfun.internal.cacheExist(nm,'class') == 8
        % Does exist think it is a class?
        tf = true;
    end
end