function t = readtable(filename,varargin)
%READTABLE Create a table by reading from a file.
%   Use the READTABLE function to create a table by reading column-oriented data
%   from a file.  READTABLE can automatically determine the file format from its
%   extension as described below.
%
%   T = READTABLE(FILENAME) creates a table by reading from the file FILENAME,
%   and determines the file format from its extension.  The extension must be
%   one of those listed below.
%
%   T = READTABLE(FILENAME,'FileType',FILETYPE) specifies the file type, where
%   FILETYPE is one of 'text' or 'spreadsheet'.
%
%   READTABLE reads data from different file types as follows:
%
%   .txt, .dat, .csv:  Delimited text file (comma-delimited by default).
%
%          Reading from a delimited text file creates one variable in T for
%          each column in the file.  Variable names are taken from the first row
%          of the file.  By default, the variables created are either double,
%          if the entire column is numeric, or cell array of strings, if any
%          element in a column is not numeric.  READTABLE converts empty fields
%          in the file to either NaN (for a numeric variable) or the empty string
%          (for a string-valued variable). Insignificant whitespace in the file
%          is ignored.
%
%          Use the following optional parameter name/value pairs to control how
%          data are read from a delimited text file:
%
%          'Delimiter'     The delimiter used in the file.  Can be any of ' ',
%                          '\t', ',', ';', '|' or their corresponding string
%                          names 'space', 'tab', 'comma', 'semi', or 'bar'.
%                          Default is ','.
%
%          'ReadVariableNames'  A logical value that specifies whether or not the
%                          first row (after skipping HeaderRows) of the file is
%                          treated as variable names.  Default is true.
%
%          'ReadRowNames'  A logical value that specifies whether or not the
%                          first column of the file is treated as row names.
%                          Default is false.  If the 'ReadVariableNames' and
%                          'ReadRowNames' parameter values are both true, the
%                          name in the first column of the first row is saved
%                          as the first dimension name for the table.
%
%          'TreatAsEmpty'  One or more strings to be treated as the empty string
%                          in a numeric column.  This may be a character string,
%                          or a cell array of strings.  Table elements
%                          corresponding to these are set to NaN.  'TreatAsEmpty'
%                          only applies to numeric columns in the file, and
%                          numeric literals such as '-99' are not accepted.
%
%          'HeaderLines'   The number of lines to skip at the beginning of the
%                          file.
%
%          'Format'        A format string to define the columns in the file, as
%                          accepted by the TEXTSCAN function.  If you specify 'Format',
%                          you may also specify any of the parameter name/value pairs
%                          accepted by the TEXTSCAN function.  Type "help textscan" for
%                          information about format strings and additional parameters.
%                          Specifying the format can significantly improve speed for
%                          some large files.
%
%   .xls, .xlsx, .xlsb, .xlsm, .xltm, .xltx, .ods:  Spreadsheet file.
%
%          Reading from a spreadsheet file creates one variable in T for each column
%          in the file.  By default, the variables created are either double, or cell
%          array of strings.  Variable names are taken from the first row of the
%          spreadsheet.
%
%          Use the following optional parameter name/value pairs to control how
%          data are read from a spreadsheet file:
%
%          'ReadVariableNames'  A logical value that specifies whether or not the
%                          first row of the specified region of the file is treated
%                          as variable names.  Default is true.
%
%          'ReadRowNames'  A logical value that specifies whether or not the first
%                          column of specified region of the file is treated as row
%                          names.  Default is false.  If the 'ReadVariableNames'
%                          and 'ReadRowNames' parameter values are both true, the
%                          name in the first column of the first row is saved as
%                          the first dimension name for the table.
%
%          'TreatAsEmpty'  One or more strings to be treated as an empty cell
%                          in a numeric column.  This may be a character string,
%                          or a cell array of strings.  Table elements
%                          corresponding to these are set to NaN.  'TreatAsEmpty'
%                          only applies to numeric columns in the file, and
%                          numeric literals such as '-99' are not accepted.
%
%          'Sheet'         The sheet to read, specified as a string that contains
%                          the worksheet name, or a positive integer indicating the
%                          worksheet index.
%
%          'Range'         A string that specifies a rectangular portion of the
%                          worksheet to read, using the Excel A1 reference
%                          style.  If the spreadsheet contains figures or other
%                          non-tabular information, you should use the 'Range'
%                          parameter to read only the tabular data.  By default,
%                          READTABLE reads data from a spreadsheet contiguously
%                          out to the right-most column that contains data,
%                          including any empty columns that precede it.  If the
%                          spreadsheet contains one or more empty columns
%                          between columns of data, use the 'Range' parameter to
%                          specify a rectangular range of cells from which to
%                          read variable names and data.
%
%          'Basic'         A logical value specifying whether or not to read the
%                          spreadsheet in basic mode. Basic mode is the default
%                          for systems without Excel for Windows installed. See
%                          the documentation for XLSREAD for more information.
%
%   See also WRITETABLE, TABLE, TABLE/WRITE, TEXTSCAN, XLSREAD.

%   Copyright 2012-2013 The MathWorks, Inc.

t = table.readFromFile(filename,varargin);
