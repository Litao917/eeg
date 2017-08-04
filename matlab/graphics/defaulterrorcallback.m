function defaulterrorcallback(h, evt)
% The default value for ErrorCallback properties.

%   Copyright 2009-2012 The MathWorks, Inc.
[id, msg] = prepareWarning(h,evt);
[stack, wsIndex] = dbstack('-completenames');
if (size(stack,1) == 1)
    warningstatus = warning('OFF', 'BACKTRACE');
    warning(id, msg);
    warning(warningstatus);
else
    warning(id, msg);
end

end

function [id,msg] = prepareWarning(h,evt)

k = evt.error;
a = k.Cause;

if (~isempty(a) && strcmp(a.ID, 'MATLAB:handle_graphics:exceptions:Property'))
    [id, msg] = preparePropertyWarning(k, a);
else
    [id, msg] = perpareOtherWarning(evt, k);
end
end

function [id, msg] = preparePropertyWarning(k, a)
    msg = ' ';
    if (isprop(k, 'Object'))
        objectType = class(k.Object);
        simpleObjectType = simpleName(objectType);
        if (isprop(a, 'Properties'))
            m = size(a.Properties, 2);
            c = a.Cause;
            if (m == 1)
                try
                    s = sprintf(' <a href="matlab:helpview([docroot,''/matlab/ref/%s_props.html#%s''])">%s</a>', simpleObjectType, a.Properties{1},a.Properties{1});
                catch e
                    s = k.Properties{1};
                end
                msg = sprintf('%s', getString(message('MATLAB:defaulterrorcallback:ErrorInProperty', simpleObjectType, s, c.Message)));
            else
                mssg1 = '';
                for i=1:m
                    try
                        s = sprintf(' <a href="matlab:helpview([docroot,''/matlab/ref/%s_props.html#%s''])">%s</a>', simpleObjectType, a.Properties{i},a.Properties{i});
                    catch e
                        s = sprintf('%s', a.Properties{i});
                    end
                    mssg1 = [mssg1, s];
                end
                mssg = mssg1;
                msg = sprintf('%s', getString(message('MATLAB:defaulterrorcallback:ErrorInMultipleProperties', simpleObjectType, mssg, c.Message)));
            end
            id = c.ID;
        else
            id = a.ID;
            msg = sprintf('%s', getString(message('MATLAB:defaulterrorcallback:ErrorInProperty', simpleObjectType, ' ', ' ')));
        end
    else
        id = k.ID;
        msg = k.Message;
    end
end

function [id, msg] = perpareOtherWarning(evt, k)

    if (~isempty(k))
        while (~isempty(k))

            if(strcmp(k.id,'MATLAB:handle_graphics:exceptions:SceneNode'))
                sn = simpleName(class(k.Object));
                k.message = sprintf('%s\n', getString(message('MATLAB:defaulterrorcallback:ErrorUpdating', sn)));
            end
            k = k.Cause;

        end
        msg = prepareWarningMsg(evt.error.message, evt.error.cause);
        id = evt.error.id;
    end

end

function dstmsg = prepareWarningMsg(srcmsg, cause)

if isempty(cause)
    dstmsg = srcmsg;
else
    tmpmsg = [srcmsg '\n ' cause.message '\n'];
    dstmsg = prepareWarningMsg(tmpmsg, cause.cause);
    
end
end

function smplname = simpleName(fullName)
[token, remain] = strtok(fullName, '.');
while (~isempty(remain))
    [token, remain] = strtok(remain, '.');
end
smplname = token;
end

