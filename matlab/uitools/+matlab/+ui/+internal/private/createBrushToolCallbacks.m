function result = createBrushToolCallbacks()

replaceNaN = {@datamanager.dataEdit 'replace' NaN};
replaceConst = {@datamanager.dataEdit 'replace'};
remove = {@datamanager.dataEdit 'remove' false};
removeUnbr = {@datamanager.dataEdit 'remove' true};
newVar = {@datamanager.newvar};
paste = {@datamanager.paste};
copy = {@datamanager.copySelection};

result = {replaceNaN replaceConst remove removeUnbr newVar paste copy};

end
