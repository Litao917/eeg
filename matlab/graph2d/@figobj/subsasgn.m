function A = subsasgn(A,S,B)
%FIGOBJ/SUBSASGN Subscripted assignment for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

switch S.type
case '.'
   switch lower(S.subs)
   case 'notes'
      A.Notes = B;
   case 'date'
      A.Date = B;
   case 'origin'
      A.Origin = B;
   case 'savedposition'
      A.SavedPosition = B;
   case 'dragobjects'
      A.DragObjects = B;
   otherwise
      hgObj = A.scribehgobj;
      A.scribehgobj = subsasgn(hgObj,S,B);
   end
end
