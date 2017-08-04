classdef FileClassifier < handle

    properties (Access = private)
        knownLanguages
        knownTypes
    end

    methods (Access = private)
        function initProperties(obj)
            % Learn languages. The language names must match those in the
            % database table 'language'.
            lm = containers.Map;
            lm('.m') = 'MATLAB';
            lm('.p') = 'MATLAB';
            lm('.mlx') = 'MATLAB';
            lm(['.' mexext]) = 'MATLAB';
            lm('.mat') = 'MATLAB';
            lm('.fig') = 'MATLAB';
            lm('.cpp') = 'CPP';
            lm('.java') = 'Java';
            lm('.cs') = 'NET';
            obj.knownLanguages = lm;
        end
    end

    methods

        function obj = FileClassifier()
            initProperties(obj);
        end

        function [lang, type] = classify(obj, file)
            [~,~,ext] = fileparts(file);
            data = 'Data';
            lang = data;
            type = matlab.depfun.internal.MatlabType.NotYetKnown;
            if isKey(obj.knownLanguages, ext)
                lang = obj.knownLanguages(ext);
            end
            if strcmp(lang, 'MATLAB')
                switch ext
                  case ['.' mexext]
                    type = matlab.depfun.internal.MatlabType.Function;
                  case {'.fig', '.mat'}
                    type = matlab.depfun.internal.MatlabType.Data;
                end
            else
                type = matlab.depfun.internal.MatlabType.Extrinsic;
            end
        end
    end
end
