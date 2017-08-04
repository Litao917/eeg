function helpmenufcn(hfig, cmd)
% This function is undocumented and will change in a future release

%HELPMENUFCN Implements part of the figure help menu.
%  HELPMENUFCN(H, CMD) invokes help menu command CMD in figure H.
%
%  CMD can be one of the following:
%
%    HelpGraphics
%    HelpPlottingTools
%    HelpAnnotatingGraphs
%    HelpPrintingExport
%    HelpDemos
%    HelpAbout

%  Copyright 1984-2012 The MathWorks, Inc.

switch cmd
    case 'HelpmenuPost'
        % FOR INTERNAL USE.
        if ismac
            % If on Mac, hide items already in the MATLAB menu
            helpAbout = findobj(allchild(gcbo),'tag','figMenuHelpAbout');
            set(helpAbout,'Visible','off');
        end

        if isstudent
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuHelpUpdates'), 'Visible','off');
                set(findobj(allchild(gcbo),'tag','figMenuGetTrials'), 'Visible','off');
            end
        else
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuHelpActivation'), 'Visible','off');
                set(findobj(allchild(gcbo),'tag','figMenuTutorials'), 'Visible','off');
            end
        end
    case 'HelpGraphics'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'creating_plots')
    case 'HelpPlottingTools'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'matlab_plotting_tools')
    case 'HelpAnnotatingGraphs'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'annotating_graphs')
    case 'HelpPrintingExport'
        helpview([docroot '/techdoc/creating_plots/creating_plots.map'],'print_collection_intro')
    case 'HelpDemos'
        demo
    case 'HelpMLTutorials'
        relNbr = version('-release');
        theUrl = ['http://www.mathworks.com/academia/student_center/tutorials/mltutorial_launchpad.html?s_cid=0310_ptow_sv_tutorial_matlab_R' relNbr];
        web(theUrl, '-browser');
    case 'HelpSLTutorials';
        relNbr = version('-release');
        theUrl = ['http://www.mathworks.com/academia/student_center/tutorials/sltutorial_launchpad.html?s_cid=0310_ptow_sv_tutorial_simulink_R' relNbr];
        web(theUrl, '-browser');
    case 'HelpActivation'
        StudentActivationStatus
    case 'HelpTerms'
        web(strcat(matlabroot,'/license.txt'));
    case 'HelpPatents'
        web(strcat(matlabroot,'/patents.txt'));
    case 'HelpAbout'
        uimenufcn(hfig, 'HelpAbout');
end

