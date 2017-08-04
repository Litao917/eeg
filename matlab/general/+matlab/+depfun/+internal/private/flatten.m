function data = flatten(data)
% flatten Flatten a cell array (remove all nesting).

    if iscell(data)
        data = cellfun(@flatten,data,'UniformOutput',false);
        if any(cellfun(@iscell,data))
            data = [data{:}];
        end
    end
end



