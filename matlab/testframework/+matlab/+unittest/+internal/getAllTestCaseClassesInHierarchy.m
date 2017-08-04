function allClasses = getAllTestCaseClassesInHierarchy(metacls)

% Copyright 2013 The MathWorks, Inc.

validateattributes(metacls,{'matlab.unittest.meta.class'}, {'scalar'}, '', 'metacls');

allClasses = metacls;
toExamine = metacls;

while ~isempty(toExamine)
    for superclass = rot90(toExamine(1).SuperclassList, 3)
        if metaclass(superclass) <= ?matlab.unittest.meta.class && all(allClasses ~= superclass)
            allClasses = [superclass, allClasses]; %#ok<AGROW>
            toExamine = [toExamine, superclass]; %#ok<AGROW>
        end
    end
    toExamine(1) = [];
end
end

% LocalWords:  metacls
