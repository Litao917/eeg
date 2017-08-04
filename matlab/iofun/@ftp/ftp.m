function h = ftp(host,username,password,varargin)
% FTP Create an FTP object.
%    FTP(host,username,password) returns an FTP object.  If only a host is 
%    specified, it defaults to "anonymous" login.
%
%    An alternate port can be specified by separating it from the host name
%    with a colon.  For example: ftp('ftp.mathworks.com:34')

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2012 The MathWorks, Inc.

% Our FTP implementation uses code from the Apache Jakarta Project.
% Copyright (c) 2001 The Apache Software Foundation.  All rights reserved.

if ~usejava('jvm')
    error(message('MATLAB:ftp:Java'))
end

% Short-circuit cases.
if (nargin == 0)
   % All MATLAB objects need a default constructor.  It is useless, though.
   % Immutable fields.
   h.jobject = org.apache.commons.net.ftp.FTPClient;
   h.host = '';
   h.port = 21;
   h.username = '';
   h.password = '';
   % Mutable fields.  Use StringBuffers so these will act as references.
   h.remotePwd = java.lang.StringBuffer('');
   h.type = java.lang.StringBuffer('binary');
   % Make the cast.
   h = class(h,'ftp');
   return
elseif isa(host,'ftp')
   % If given an FTP object, give it back.
   h = host;
   return
end

% Argument parsing
if (nargin < 1)
error(message('MATLAB:ftp:IncorrectArgumentCount'))
end
if (nargin < 2)
    username = 'anonymous';
end
if (nargin < 3)
    password = 'anonymous@example.com';
end
options = parseInputs(varargin);

% Immutable fields.
h.jobject = org.apache.commons.net.ftp.FTPClient;
colon = find(host==':');
if isempty(colon)
    h.host = host;
    h.port = 21;
else
    h.host = host(1:colon-1);
    h.port = str2double(host(colon+1:end));
end
h.username = username;
h.password = password;

% Mutable fields.  Use StringBuffers so these will act as references.
h.remotePwd = java.lang.StringBuffer('');
h.type = java.lang.StringBuffer('binary');

configureFtpClient(h.jobject,options)

% Make the cast.
h = class(h,'ftp');

% Connect.
connect(h)

function options = parseInputs(args)
% Agrument parsing
p = inputParser;
p.addParamValue('System','',@ischar)
p.addParamValue('LenientFutureDates',[],@islogical)
p.addParamValue('DefaultDateFormatStr','',@ischar)
p.addParamValue('RecentDateFormatStr','',@ischar)
p.addParamValue('ServerLanguageCode','',@ischar)
p.addParamValue('ServerTimeZoneId','',@ischar)
p.addParamValue('ShortMonthNames','',@ischar)
p.parse(args{:})
options = p.Results;

function configureFtpClient(jobject,options)
if any(structfun(@(x)~isempty(x),options))
    import org.apache.commons.net.ftp.FTPClientConfig
    if isempty(options.System)
        system = 'UNIX';
    else
        system = upper(options.System);
    end
    conf = FTPClientConfig(['SYST_' system]);
    options = rmfield(options,'System');
    fields = fieldnames(options);
    for iFields = 1:numel(fields);
        field = fields{iFields};
        if ~isempty(options.(field))
            javaMethod(['set' field],conf,options.(field))
        end
    end
    jobject.configure(conf);
end
