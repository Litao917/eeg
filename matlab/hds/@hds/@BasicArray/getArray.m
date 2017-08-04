function A = getArray(this)
%GETARRAY  Reads array value.
%
%   Array = GETARRAY(ValueArray)

%   Copyright 1986-2004 The MathWorks, Inc.

% Perf optimization: more elegant code
%    A = this.MetaData.getData(this.Data)
% takes too long even when getData does nothing. Now 
% relying on subclassing for implicit storage support
A = this.Data;
