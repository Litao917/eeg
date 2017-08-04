classdef (Hidden) EnumType < hgsetget
    %ENUMTYPE compatible schema.EnumType
    %   obj = matlab.internal.EnumType(Strings)
    %   obj = matlab.internal.EnumType(Strings,Values)
    %
    %   EnumType properties:
    %     Strings - list of strings for EnumType
    %     Values - values associated with strings
    %   EnumType methods:
    %     check - check string belongs to EnumType
    
    %   Copyright 2011-2012 The MathWorks, Inc.
    
    properties (Dependent)
        %STRINGS - list of strings for EnumType
        Strings = {};
        %VALUES- values associated with strings
        Values = [];
    end
    
    properties (Access=private)
        %STRINGS - list of strings for EnumType
        pStrings = {};
        %VALUES- values associated with strings
        pValues = [];
    end    
    
    methods
        function obj = EnumType(Strings,Values)
            %ENUMTYPE constructor 
            %   obj = matlab.internal.EnumType(Strings)
            %   obj = matlab.internal.EnumType(Strings,Values)
            
            if nargin<2
                Values = 0:length(Strings)-1;
            end
            obj.Strings = Strings;
            obj.Values = Values;
            
        end
        
        function set.Strings(obj,value)
        
        % convert to a cell string or error
        value = cellstr(value);
        if length(value)~=length(obj.pValues)
            % make values length compatible
            obj.pValues = 0:length(value)-1;
        end
        obj.pStrings = value;
        end
        function s = get.Strings(obj)
        s = obj.pStrings;
        end
        
        function set.Values(obj,value)
        if length(value)==length(obj.pStrings)
            obj.pValues = value;
        end
        end
        
        function v = get.Values(obj)
        v = obj.pValues;
        end
        
        
        
        function string=check(obj,value,VarName)
            %CHECK check string belongs to EnumType  
            %    string = check(obj,string);
            %    The full name of the enumeration is returned.
            if nargin<3
                VarName = '';
            end
            
            if isnumeric(value) && isscalar(value)
                OK = value == obj.Values;
                if nnz(OK)==1
                    value = obj.Strings{OK};
                end
            end
            string=validatestring(value,obj.Strings,'',VarName);
            
        end
        
    end
    
end

