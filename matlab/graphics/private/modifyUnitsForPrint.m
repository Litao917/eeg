function [ objUnitsModified, objFontUnitsModified ] = modifyUnitsForPrint(...
    modifyRevertFlag, varargin)
% MODIFYUNITSFORPRINT Modifies or restores a figure's axes and other
% object's units for printing. This undocumented helper function is for
% internal use.

% This function is called during the print path.  See usage in
% alternatePrintPath.m

% MODIFYUNITSFORPRINT('modify', h) can be used to modify the units of the
% axes and other objects.  The return will be: [objUnitsModified,
% objFontUnitsModified], which are cell arrays of the objects whose units
% were set to normalized, and whose FontUnits properties was set to
% normalized. The modifyRevertFlag can be used when calling this function
% to 'revert'.

% MODIFYUNITSFORPRINT('revert', h, pixelObjects, fontPixelObjects) reverts
% the units to their original values, before 'modify' was called.

% Copyright 2013 The MathWorks, Inc.

narginchk(2, 3)

% The set of units to modify
unitsToModify = {'centimeters', 'inches', 'characters', 'pixels', 'points'};

if strcmp(modifyRevertFlag, 'modify') && length(varargin) == 1
    h = varargin{1};
    
    % Find all objects with units of centimeters, inches, characters, or
    % pixels, and change them to normalized so they can be printed
    % appropriately.  They will be stored as fields in struct
    % objUnitsModified
    for i=1:length(unitsToModify)
        objUnitsModified.(unitsToModify{i}) = getObjWithUnits(h, ...
            'Units', unitsToModify{i});

        objFontUnitsModified.(unitsToModify{i}) = getObjWithUnits(h, ...
            'FontUnits', unitsToModify{i});
    end
    
    unitsModified = structfun(@(x) ~isempty(x), objUnitsModified);
    if any(unitsModified)
        % If any units need changing, set them to normalized
        unitsToChange = unitsToModify(unitsModified);
        for i=1:length(unitsToChange)
            set(objUnitsModified.(unitsToChange{i}), ...
                'Units', 'normalized')
        end
    end
    
    % Same thing for objects with FontUnits set to centimeters, inches,
    % characters, or pixels.
    fontUnitsModified = structfun(@(x) ~isempty(x), objFontUnitsModified);
    if any(fontUnitsModified)
        fontUnitsToChange = unitsToModify(fontUnitsModified);
        for i=1:length(fontUnitsToChange)
            set(objFontUnitsModified.(fontUnitsToChange{i}), ...
                'FontUnits', 'normalized')
        end
    end
    
elseif strcmp(modifyRevertFlag, 'revert') && length(varargin) == 2
    objUnitsModified = varargin{1};
    objFontUnitsModified = varargin{2};
    
    % Revert units for objects which were modified
    for i=1:length(unitsToModify)
        if ~isempty(objUnitsModified.(unitsToModify{i}))
            if all(ishghandle(objUnitsModified.(unitsToModify{i})))
                set(objUnitsModified.(unitsToModify{i}), ...
                    'Units', unitsToModify{i})
            end
        end
    end
    
    % Same for FontUnits
    for i=1:length(unitsToModify)
        if ~isempty(objFontUnitsModified.(unitsToModify{i}))
            set(objFontUnitsModified.(unitsToModify{i}), ...
                'FontUnits', unitsToModify{i})
        end
    end
else
    error(message('MATLAB:modifyunitsforprint:invalidFirstArgument'))
end

    function objWithUnits = getObjWithUnits(h, unitsProp, units)
        % Returns an array of objects which have the unitsProp property
        % value set to the specified units.
        objWithUnits = findall(h, '-property', unitsProp, unitsProp, units);
        
        % Don't include the figure itself in this list
        objWithUnits = objWithUnits(~ishghandle(objWithUnits, 'figure'));
    end
end

