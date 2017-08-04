function selector = convertParsingResultsToSelector(selectionCriteria)

% Copyright 2013 The MathWorks, Inc.

selectors = {};

selectors = [selectors, {handleSelectorInput(selectionCriteria)}];
selectors = [selectors, {handleParameterization(selectionCriteria)}];
selectors = [selectors, {handleName(selectionCriteria)}];
selectors = [selectors, {handleBaseFolder(selectionCriteria)}];

selector = combineSelectors(selectors);
end

function selector = handleSelectorInput(selectionCriteria)
if isfield(selectionCriteria, 'Selector')
    validateattributes(selectionCriteria.Selector, ...
        {'matlab.unittest.internal.selectors.Selector'}, {'scalar'}, '', 'selector');
    selector = selectionCriteria.Selector;
else
    selector = {};
end
end

function selector = handleParameterization(selectionCriteria)
import matlab.unittest.selectors.HasParameter;

% Need to create a HasParameter selector when one or both of
% 'ParameterProperty' and 'ParameterName' was specified.
hasParameterProperty = isfield(selectionCriteria, 'ParameterProperty');
hasParameterName = isfield(selectionCriteria, 'ParameterName');

if hasParameterProperty || hasParameterName
    propertyArgs = {};
    if hasParameterProperty
        propertyArgs = {'Property', convertStringToMatchesConstraint(selectionCriteria.ParameterProperty)};
    end
    
    nameArgs = {};
    if hasParameterName
        nameArgs = {'Name', convertStringToMatchesConstraint(selectionCriteria.ParameterName)};
    end
    
    selector = HasParameter(propertyArgs{:}, nameArgs{:});
else
    selector = {};
end
end

function selector = handleName(selectionCriteria)
import matlab.unittest.selectors.HasName;

if isfield(selectionCriteria, 'Name')
    selector = HasName(convertStringToMatchesConstraint(selectionCriteria.Name));
else
    selector = {};
end
end

function selector = handleBaseFolder(selectionCriteria)
import matlab.unittest.selectors.HasBaseFolder;

if isfield(selectionCriteria, 'BaseFolder')
    selector = HasBaseFolder(convertStringToMatchesConstraint(selectionCriteria.BaseFolder));
else
    selector = {};
end
end

function constraint = convertStringToMatchesConstraint(string)
import matlab.unittest.constraints.Matches;
validateattributes(string, {'char'}, {'row'});
constraint = Matches(['^', regexptranslate('wildcard',string), '$']);
end

function selector = combineSelectors(selectors)
import matlab.unittest.internal.selectors.NeverFilterSelector;

selectors = selectors(cellfun(@(s)~isempty(s), selectors));

if isempty(selectors)
    selector = NeverFilterSelector;
else
    % Use AND operator to combine all the individual selectors together
    % into a single AndSelector.
    selector = selectors{1};
    for idx = 2:numel(selectors)
        selector = selector & selectors{idx};
    end
end
end
