function clearscribe(fig)

  if ~graphicsversion(fig,'handlegraphics')
    scribeax = findall(fig,'Type','annotationpane');
  else
    scribeax = getappdata(fig,'Scribe_ScribeOverlay');
  end
  if any(ishghandle(scribeax)),
    for ix=1:numel(scribeax)
        delete(get(scribeax(ix),'Children'));
    end
  end
  
