function [v6, cax, args] = parseplotapi(varargin)
    % This undocumented function may be removed in a future release
    
    %USEHGPLOTAPI determine plotting version
    %  Checks to see which HG plotting API should be used.
    
    %   Copyright 2010, 2011 The MathWorks, Inc.
   
    
    % Is the v6 flag passed? 
    [v6,args] = usev6plotapiHGUsingMATLABClasses(varargin{:});

    % Parse args for axes parent
    [cax, args] = axescheck(args{:});
    
end

