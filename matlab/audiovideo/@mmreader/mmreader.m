classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
         mmreader < hgsetget
%   MMREADER has been removed.  Use VIDEOREADER instead.

%   Authors: NH DL
%   Copyright 2005-2013 The MathWorks, Inc.
%     
   
    %------------------------------------------------------------------
    % Documented methods
    %------------------------------------------------------------------    
    methods(Access='public')

        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function obj = mmreader(fileName, varargin)
            error(message('MATLAB:audiovideo:mmreader:mmreaderToBeRemoved'));
        end

    end
end
