%   Copyright 2013 The MathWorks, Inc.
classdef Utils

    methods (Static = true)
        function state = compare(obj1,obj2,propName)
            % Java utility method for comparing a property shared by 2 
            % objects to determine if the property values are the same. 
            state = isequal(get(obj1,propName),get(obj2,propName));
        end
        
        function jobj = java(obj)
            
            if numel(obj)==1
                jobj = java(obj);
                return
            end
            jobj = javaArray(class(java(obj(1))),numel(obj));
            for k=1:numel(obj)
                jobj(k) = java(obj(k));
            end
        end
    end    
end
