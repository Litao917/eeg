function [coldata,nullval] = readCol(fptr,colnum,firstrow,numrows)
%readCol read rows of ASCII or binary table column
%   [COLDATA,NULLVAL] = readCol(FPTR,COLNUM) reads an entire column from an 
%   ASCII or binary table column.  NULLVAL is a logical array specifying if 
%   a particular element of COLDATA should be treated as undefined.  It is
%   the same size as COLDATA.
%
%   [COLDATA,NULLVAL] = readCol(FPTR,COLNUM,FIRSTROW,NUMROWS) reads a 
%   subsection of rows from an ASCII or binary table column.  
%
%   The MATLAB datatype returned by readCol corresponds to the datatype 
%   returned by getEqColType.
%
%   This function corresponds to the fits_read_col (ffgcv) function in 
%   the CFITSIO library C API.
%
%   Example:  Read an entire column.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       colnum = fits.getColName(fptr,'flux');
%       fluxdata = fits.readCol(fptr,colnum);
%       fits.closeFile(fptr);
%
%   Example:  Read the first five rows in a column.
%       import matlab.io.*
%       fptr = fits.openFile('tst0012.fits');
%       fits.movAbsHDU(fptr,2);
%       colnum = fits.getColName(fptr,'flux');
%       fluxdata = fits.readCol(fptr,colnum,1,5);
%       fits.closeFile(fptr);
%
%   See also fits, writeCol.

%   Copyright 2011-2013 The MathWorks, Inc.
                                                                                                                 
validateattributes(fptr,{'uint64'},{'scalar'},'','FPTR');
validateattributes(colnum,{'double'},{'scalar','integer'},'','COLNUM');

num_table_rows = matlab.io.fits.getNumRows(fptr);
switch(nargin)
	case 2
		firstrow = 1;
		numrows = num_table_rows;

	case 4
		validateattributes(firstrow,{'double'},{'scalar','positive','integer'},'','FIRSTROW');
		validateattributes(numrows,{'double'},{'scalar','positive','integer','<=',num_table_rows - firstrow + 1},'','NUMROWS');

	otherwise
		error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end


[coldata,nullval] = fitsiolib('read_col',fptr,colnum,firstrow,numrows);

% Transpose column data if an ASCII column and from a binary table, not if
% from an ASCII table.
if ischar(coldata) && strcmp(matlab.io.fits.getHDUtype(fptr),'BINARY_TBL')
    coldata = coldata';
end

% Transpose the output into a column.
[~,repeat] = matlab.io.fits.getColType(fptr,colnum);
if (size(coldata,1) <= repeat)
    coldata = permute(coldata,[2 1]);
    nullval = permute(nullval,[2 1]);
end

% Convert the NULLDATA to logical.
if iscell(nullval)
    nullval = cellfun(@logical,nullval,'UniformOutput',false);
else
    nullval = logical(nullval);
end
