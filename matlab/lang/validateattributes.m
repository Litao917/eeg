function validateattributes( varargin )
%VALIDATEATTRIBUTES Check validity of array.
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES) validates that array A belongs
%   to at least one of the specified CLASSES and has all of the specified
%   ATTRIBUTES. If A does not meet the criteria, MATLAB issues a formatted
%   error message.
%
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES,ARGINDEX) includes the
%   position of the input in your function argument list as part of any
%   generated error messages.
%
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES,FUNCNAME) includes the
%   specified function name in generated error identifiers.
%
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES,FUNCNAME,VARNAME) includes the
%   specified variable name in generated error messages.
%
%   VALIDATEATTRIBUTES(A,CLASSES,ATTRIBUTES,FUNCNAME,VARNAME,ARGINDEX)
%   includes the specified information in the generated error messages or
%   identifiers.
%
%   Input Arguments:
%
%   A          Any class of array.
%
%   CLASSES    Cell array of strings that specify valid classes for array A.
%              For example, if CLASSES = {'logical','cell'}, A must be a
%              logical array or a cell array. The string 'numeric' is an
%              abbreviation for the classes uint8, uint16, uint32, uint64,
%              int8, int16, int32, int64, single, double.
%
%   ATTRIBUTES Cell array that contains descriptions of valid attributes
%              for array A. For example, if ATTRIBUTES = {'real','finite'}
%              A must contain only real and finite values.
%
%              Supported attributes include:
%   
%                2d         3d         binary       ndims           nonzero        
%                 <      ncols          nrows      column       nonnegative
%                <=       size       nonempty        real        decreasing
%                 >        odd      nonsparse      nonnan        increasing
%                >=      numel         scalar      square     nondecreasing
%               row       diag        integer      vector     nonincreasing
%              even     finite       positive
%                                 
%
%              Some attributes also require numeric values. For those 
%              attributes, the numeric value or vector must immediately 
%              follow the attribute name string. For example,
%              {'>=', 5, '<=', 10, 'size', [3 4 2]} checks that all
%              values of A are between 5 and 10, and that A is 3-by-4-by-2.
%
%   ARGINDEX   Positive integer that specifies the position of the input
%              argument.
%
%   FUNCNAME   String that specifies the function name. If you specify an
%              empty string, '', FUNCNAME is ignored.
%
%   VARNAME    String that specifies input argument name. If you specify an
%              empty string, '', VARNAME is ignored.
%
%
%   Example: Create a three dimensional array and then check for the
%            attribute '2d'.
%
%       A = [ 1 2 3; 4 5 6 ];
%       B = [ 7 8 9; 10 11 12];
%       C = cat(3,A,B);
%       validateattributes(C,{'numeric'},{'2d'},'my_func','my_var',2)
%
%   This code throws an error and displays a formatted message:
%
%       Expected input number 2, my_var, to be two-dimensional.
%
%   See also validatestring, inputParser.

%   Copyright 1993-2013 The MathWorks, Inc.
