function [strings,err] = bfitcheckfitbox(checkon,...
    datahandle,fit,showeqnon,digits,plotresidon,plottype,subploton,showresidon)
%

%   Copyright 1984-2012 The MathWorks, Inc.

strings = ' ';
err = 0;

axesH = ancestor(datahandle,'axes'); % need this in case subplots in figure
figH = ancestor(axesH,'figure');
bfitlistenoff(figH)

if checkon
    % calculate fit and get resulting strings of info
    [strings, err, pp] = bfitcalcfit(datahandle,fit);
    if err
        dlgh = getappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle');
        if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
            figure(dlgh);
        end
        bfitlistenon(figH)
        return
    end
    
    % plot the curve/fit
    bfitplotfit(datahandle,axesH,figH,pp,fit);
    
    % update the legend so it's stuff + fits + evalresults
    bfitcreatelegend(axesH);
    
    % add equations to plot
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
    
else % check off

    fitshandles = double(getappdata(double(datahandle),'Basic_Fit_Handles'));
    fitsshowinglogical = getappdata(double(datahandle),'Basic_Fit_Showing');
    % delete fitline from plot
    if ishghandle(fitshandles(fit+1)) && ~strcmpi(get(fitshandles(fit+1),'beingdeleted'),'on')
        delete(fitshandles(fit+1))
    end
    
    % Inf out the fitshowing appdata
    fitshandles(fit+1) = Inf;
    setgraphicappdata(double(datahandle),'Basic_Fit_Handles',fitshandles);
    fitsshowinglogical(fit+1) = false;
    setappdata(double(datahandle),'Basic_Fit_Showing',fitsshowinglogical);
    
    % update legend
    bfitcreatelegend(axesH);
    
    % update eqntxt
    bfitcheckshowequations(showeqnon, datahandle, digits)
    
    % plot resids with other info on plot
    bfitcheckplotresiduals(plotresidon,datahandle,plottype,subploton,showresidon)
   
end
dlgh = double(getappdata(double(datahandle),'Basic_Fit_Dialogbox_Handle'));
if ishghandle(dlgh) % if error or warning appeared, make sure it is on top
    figure(dlgh);
end
bfitlistenon(figH)
