function ts = gettsbeforeatevent(this,event,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

ts = this.copy;
ts.TsValue = gettsbeforeatevent(this.Tsvalue,event,varargin{:});



