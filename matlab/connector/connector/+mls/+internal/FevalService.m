classdef FevalService < mls.internal.HttpService
    methods
        function service = FevalService
            mls.internal.HttpService.registerService('feval', service);
        end
        
        function doGet(obj, httpRequest, httpResponse)
            pathParts = regexp(httpRequest.Path, '/', 'split');
            if numel(pathParts) == 2
                decoder = java.net.URLDecoder;
                arguments = '';
                if httpRequest.Parameters.isKey('arguments')
                    arguments = char(decoder.decode(httpRequest.Parameters('arguments')));
                end
                outputs = 0;
                if httpRequest.Parameters.isKey('nargout')
                    outputs = str2double(char(decoder.decode(httpRequest.Parameters('nargout'))));
                end
                results = mls.internal.fevalJSON(pathParts{2}, arguments, outputs);
                if outputs > 0
                    httpResponse.Data = results;
                    httpResponse.ContentType = 'application/json';
                else
                    httpResponse.ContentType = 'text/html';
                    httpResponse.StatusCode = 204;
                end
            end
        end
    end
end

