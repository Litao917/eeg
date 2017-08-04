function toolstrip = showcase()
% SHOWCASE  Demonstrate how to build toolstrip hierarchy in MATLAB.
%
%   obj = matlab.ui.internal.toolstrip.showcase() provides examples about
%   how to create controls, build layout and attach callback functions
%   using the Toolstrip MCOS API. The static method returns an
%   "matlab.ui.internal.toolstrip.Toolstrip" object.
%
%   To display toolstrip, open a Chrome web browser with the link below: 
%         http://localhost:31415/toolbox/matlab/toolstrip/web/showcase.html
%
%   To destroy the toolstrip, delete the toolstrip MCOS object or clear it
%   from workspace.  The UI will also be destroyed in the web browser.

%   Author(s): Rong Chen
%   Copyright 2013 The MathWorks, Inc.

    import matlab.ui.internal.toolstrip.*
    
    %% start connector if necessary
    oldstatus = connector('status');
    if ~oldstatus
        connector('localhostonly');
    end
    
    %% Toolstrip
    toolstrip = matlab.ui.internal.toolstrip.Toolstrip();
    toolstrip.Tag = 'toolstrip';
    toolstrip.DisplayStateChangedFcn = @PropertyChangedCallback;            

    %% TabGroup 1
    tabgroup1 = toolstrip.addTabGroup();
    tabgroup1.Tag = 'tabgroup1';
    tabgroup1.SelectedTabChangedFcn = @SelectedTabChangedCallback;            

    %% Tab 1
    disp('building first tab...')
    tab1 = tabgroup1.addTab('BASIC CONTROLS 1');
    tab1.Tag = 'tab1';
    tab1.add(buildPushButtonSection());
    tab1.add(buildDropDownButtonSection());
    tab1.add(buildSplitButtonSection());
    tab1.add(buildToggleButtonSection());
    tab1.add(buildToggleButtonWithGroupSection());

    %% Tab 2
    disp('building second tab...')
    tab2 = tabgroup1.addTab('BASIC CONTROLS 2');
    tab2.Tag = 'tab2';
    tab2.add(buildLabelSection());
    tab2.add(buildCheckBoxSection());
    tab2.add(buildRadioButtonSection());
    tab2.add(buildComboBoxSection());
    tab2.add(buildTextFieldSection());
    tab2.add(buildTextAreaSection());
    tab2.add(buildSliderSection());    
    tab2.add(buildSpinnerSection());    
    
    %% TabGroup 2
    tabgroup2 = toolstrip.addTabGroup();
    tabgroup2.Tag = 'tabgroup2';
    tabgroup2.SelectedTabChangedFcn = @SelectedTabChangedCallback;            

    %% Tab 3
    disp('building third tab...')
    tab3 = tabgroup2.addTab('GALLERY');
    tab3.Tag = 'tab3';
    tab3.add(buildGallerySection());
    
    %% Tab 4
    disp('building fourth tab...')
    tab4 = tabgroup2.addTab('LAYOUTS');
    tab4.Tag = 'tab4';
    tab4.add(build321Section());            
    tab4.add(buildColumnSpanSection());
    tab4.add(buildEmptyControlSection());      
    tab4.add(buildDynamicPopupSection());      
    tab4.add(buildSharingSection());      

    %% Place toolstrip
    tabgroup1.SelectedTab = tab1;

    %% Show
    toolstrip.render('ToolStripShowCase');

end

%% Callbacks
function PropertyChangedCallback(~, event)
    % callback function
    fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',event.EventData.Property,num2str(event.EventData.OldValue),num2str(event.EventData.NewValue));
end

function ActionPerformedCallback(~, event)
    % callback function
    fprintf('Action "%s" is performed in the UI.\n', event.EventData.EventType);
end

function SelectedTabChangedCallback(~, event)
    % callback function
    if isempty(event.EventData.OldValue)
        oldvalue = '';
    else
        oldvalue = event.EventData.OldValue.Tag;
    end
    if isempty(event.EventData.NewValue)
        newvalue = '';
    else
        newvalue = event.EventData.NewValue.Tag;
    end
    fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',event.EventData.Property,oldvalue,newvalue);
end

function ValueChangedCallback(~, event)
    % callback function
    fprintf('Action "%s" is performed in the UI.  The new value is "%s"\n', event.EventData.EventType,num2str(event.EventData.Value));
end

%% Sections
function section = buildPushButtonSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('PUSH BUTTONS');
    section.Tag = 'section_pushbuttons';
    % column 1
    col1 = section.addColumn();
    col1.addEmptyControl();
    btn1 = PushButton('Small Button',Icon.MATLAB_16);
    btn1.Tag = 'pushbutton1';
    btn1.Description = 'this is a tooltip';
    btn1.ButtonPushedFcn = @ActionPerformedCallback;
    col1.add(btn1);
    col1.addEmptyControl();
    % column 2
    col2 = section.addColumn();
    btn2 = PushButton('Large Button',Icon.SIMULINK_24);
    btn2.Tag = 'pushbutton2';
    btn2.Description = 'this is a tooltip';
    btn2.ButtonPushedFcn = @ActionPerformedCallback;
    col2.add(btn2);
end

function section = buildDropDownButtonSection()
    import matlab.ui.internal.toolstrip.*
    % static popuplists
    popuplist = buildStaticPopup();
    % section
    section = Section('DROPDOWN BUTTONS');
    section.Tag = 'section_dropdownbuttons';
    % column 1
    col = section.addColumn;
    col.addEmptyControl;
    btn1 = DropDownButton('Small Button',Icon.MATLAB_16);
    btn1.Tag = 'dropdownbutton1';
    btn1.Description = 'this is a tooltip';
    btn1.Popup = popuplist;
    col.add(btn1);
    col.addEmptyControl;
    % column 2
    col = section.addColumn;
    btn2 = DropDownButton('Large Button',Icon.SIMULINK_24);
    btn2.Tag = 'dropdownbutton2';
    btn2.Description = 'this is a tooltip';
    btn2.Popup = popuplist;
    col.add(btn2);
end

function section = buildSplitButtonSection()
    import matlab.ui.internal.toolstrip.*
    % static popuplists
    popuplist = buildStaticPopup();
    % section
    section = Section('SPLIT BUTTONS');
    % column 1
    col = section.addColumn;
    col.addEmptyControl;
    btn1 = SplitButton('Small Button',Icon.MATLAB_16);
    btn1.Tag = 'splitbutton1';
    btn1.Description = 'this is a tooltip';
    btn1.Popup = popuplist;
    btn1.ButtonPushedFcn = @ActionPerformedCallback;
    col.add(btn1);
    col.addEmptyControl;
    % column 2
    col = section.addColumn;
    btn2 = SplitButton('Large Button',Icon.SIMULINK_24);
    btn2.Tag = 'splitbutton2';
    btn2.Description = 'this is a tooltip';
    btn2.Popup = popuplist;
    btn1.ButtonPushedFcn = @ActionPerformedCallback;
    col.add(btn2);
end

function section = buildToggleButtonSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('TOGGLE BUTTONS (INDIVIDUAL)');
    section.Tag = 'section_togglebuttons';
    % column 1
    col = section.addColumn;
    col.addEmptyControl;
    btn1 = ToggleButton('Small Button',Icon.MATLAB_16);
    btn1.Tag = 'togglebutton1';
    btn1.Description = 'this is a tooltip';
    btn1.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn1);
    col.addEmptyControl;
    % default selection
    btn1.Selected = true;
    % column 2
    col = section.addColumn;
    btn2 = ToggleButton('Large Button',Icon.SIMULINK_24);
    btn2.Tag = 'togglebutton2';
    btn2.Description = 'this is a tooltip';
    btn2.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn2);
end

function section = buildToggleButtonWithGroupSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('TOGGLE BUTTONS (GROUP)');
    section.Tag = 'section_togglebuttons_group';
    grp = ButtonGroup();
    % column 1
    col = section.addColumn;
    btn1 = ToggleButton('Button 1',Icon.CUT_24,grp);
    btn1.Tag = 'togglebutton3';
    btn1.Description = 'this is a tooltip';
    btn1.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn1);
    % default selection
    btn1.Selected = true;
    % column 2
    col = section.addColumn;
    btn2 = ToggleButton('Button 2',Icon.COPY_24,grp);
    btn2.Tag = 'togglebutton4';
    btn2.Description = 'this is a tooltip';
    btn2.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn2);
    % column 3
    col = section.addColumn;
    btn3 = ToggleButton('Button 3',Icon.PASTE_24,grp);
    btn3.Tag = 'togglebutton5';
    btn3.Description = 'this is a tooltip';
    btn3.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn3);
end

function section = buildLabelSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('LABELS');
    section.Tag = 'section_labels';
    % column
    col = section.addColumn('HorizontalAlignment','center');
    lbl1 = Label('This is a label');
    lbl1.Description = 'this is a tooltip';
    lbl1.Tag = 'label1';
    col.add(lbl1);
    lbl2 = Label('This is a label with icon', Icon.NEW_16);
    lbl2.Tag = 'label2';
    lbl2.Description = 'this is a tooltip';
    col.add(lbl2);
end

function section = buildCheckBoxSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('CHECKBOXES');
    section.Tag = 'section_checkboxes';
    % column
    col = section.addColumn('HorizontalAlignment','right');
    chk1 = CheckBox('This is checkbox #1',true);
    chk1.Tag = 'checkbox1';
    chk1.Description = 'this is a tooltip';
    chk1.SelectionChangedFcn = @PropertyChangedCallback;
    chk1.Selected = true;
    col.add(chk1);
    chk2 = CheckBox('This is checkbox #2');
    chk2.Tag = 'checjbox2';
    chk2.SelectionChangedFcn = @PropertyChangedCallback;
    chk2.Description = 'this is a tooltip';
    col.add(chk2);
end

function section = buildRadioButtonSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('RADIO BUTTONS');
    section.Tag = 'section_radiobuttons';
    grp = ButtonGroup();
    % column
    col = section.addColumn;
    radio1 = RadioButton(grp, 'This is radio button #1');
    radio1.Tag = 'radio1';
    radio1.Description = 'this is a tooltip';
    radio1.SelectionChangedFcn = @PropertyChangedCallback;
    radio1.Selected = true;
    col.add(radio1);
    radio2 = RadioButton(grp, 'This is radio button #2');
    radio2.Tag = 'radio2';
    radio2.Description = 'this is a tooltip';
    radio2.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(radio2);
    radio3 = RadioButton(grp, 'This is radio button #3');
    radio3.Tag = 'radio3';
    radio3.Description = 'this is a tooltip';
    radio3.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(radio3);
end

function section = buildComboBoxSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('COMBO BOX');
    section.Tag = 'section_combobox';
    % column
    col = section.addColumn('Width',100);
    combo = ComboBox({'Item1', 'Label #1';'Item2', 'Label #2';'Item3', 'Label #3';'Item4', 'Label #4'});
    combo.Tag = 'combobox';
    combo.Description = 'this is a tooltip';
    combo.ItemSelectedFcn = @PropertyChangedCallback;
    col.add(combo);
end

function section = buildTextFieldSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('TEXT FIELD');
    section.Tag = 'section_textfield';
    % column
    col = section.addColumn('Width',100);
    txtfld = TextField();
    txtfld.Tag = 'textfield';
    txtfld.Description = 'this is a tooltip';
    txtfld.PlaceholderText = 'enter a text';
    txtfld.TextChangedFcn = @PropertyChangedCallback;
    col.add(txtfld);
end

function section = buildTextAreaSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('TEXT AREA');
    section.Tag = 'section_textarea';
    % column
    col = section.addColumn('Width',100);
    txtfld = TextArea();
    txtfld.Tag = 'textarea';
    txtfld.Description = 'this is a tooltip';
    txtfld.TextChangedFcn = @PropertyChangedCallback;
    col.add(txtfld);
end

function section = buildSliderSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('SLIDER');
    section.Tag = 'section_slider';
    % column
    col = section.addColumn('Width',100);
    slider = Slider(0,10,5);
    slider.Tag = 'slider';
    slider.Description = 'this is a tooltip';
    slider.ValueChangedFcn = @ValueChangedCallback;
    col.add(slider);
end

function section = buildSpinnerSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('SPINNER');
    section.Tag = 'section_spinner';
    % column
    col = section.addColumn('Width',100);
    spinner = Spinner(0,10,5);
    spinner.Tag = 'spinner';
    spinner.Description = 'this is a tooltip';
    spinner.ValueChangedFcn = @ValueChangedCallback;
    col.add(spinner);
end

function section = buildGallerySection()
    import matlab.ui.internal.toolstrip.*
    % build popup
    popup = GalleryPopup('FavoritesEnabled',true);
    popup.Tag = 'gallerypopup';
    cat1 = GalleryCategory('CATEGORY #1');
    cat1.Tag = 'category1';
    cat2 = GalleryCategory('CATEGORY #2');
    cat2.Tag = 'category2';
    cat3 = GalleryCategory('CATEGORY #3');
    cat3.Tag = 'category3';
    popup.add(cat1);
    popup.add(cat2);
    popup.add(cat3);
    item1 = GalleryItem('Biology',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','biology_app_24.png')));
    item1.Tag = 'biology';
    item1.Description = 'this is a description';
    item1.ItemPushedFcn = @ActionPerformedCallback;
    cat1.add(item1);
    item2 = GalleryItem('Code Generation',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','code_gen_app_24.png')));
    item2.Tag = 'codegen';
    item2.Description = 'this is a description';
    item2.ItemPushedFcn = @ActionPerformedCallback;
    cat1.add(item2);
    item3 = GalleryItem('Control',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','control_app_24.png')));
    item3.Tag = 'control';
    item3.Description = 'this is a description';
    item3.ItemPushedFcn = @ActionPerformedCallback;
    cat1.add(item3);
    item4 = GalleryItem('Database',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','database_app_24.png')));
    item4.Tag = 'datebase';
    item4.Description = 'this is a description';
    item4.ItemPushedFcn = @ActionPerformedCallback;
    cat1.add(item4);
    item5 = GalleryItem('Depolyment',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','deployment_app_24.png')));
    item5.Tag = 'deploy';
    item5.Description = 'this is a description';
    item5.ItemPushedFcn = @ActionPerformedCallback;
    cat1.add(item5);
    item6 = GalleryItem('Finance',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','finance_app_24.png')));
    item6.Tag = 'finance';
    item6.Description = 'this is a description';
    item6.ItemPushedFcn = @ActionPerformedCallback;
    cat2.add(item6);
    item7 = GalleryItem('Fitting Tool',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','fit_app_24.png')));
    item7.Tag = 'fittool';
    item7.Description = 'this is a description';
    item7.ItemPushedFcn = @ActionPerformedCallback;
    cat2.add(item7);
    item8 = GalleryItem('Image Processing',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','image_app_24.png')));
    item8.Tag = 'image';
    item8.Description = 'this is a description';
    item8.ItemPushedFcn = @ActionPerformedCallback;
    cat2.add(item8);
    item9 = GalleryItem('Math',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','math_app_24.png')));
    item9.Tag = 'math';
    item9.Description = 'this is a description';
    item9.ItemPushedFcn = @ActionPerformedCallback;
    cat2.add(item9);
    item10 = GalleryItem('Neural Network',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','neural_app_24.png')));
    item10.Tag = 'neural';
    item10.Description = 'this is a description';
    item10.ItemPushedFcn = @ActionPerformedCallback;
    cat2.add(item10);
    item11 = GalleryItem('Optimization',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','optim_app_24.png')));
    item11.Tag = 'optim';
    item11.Description = 'this is a description';
    item11.ItemPushedFcn = @ActionPerformedCallback;
    cat3.add(item11);
    item12 = GalleryItem('Signal Processing',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','signal_app_24.png')));
    item12.Tag = 'signal';
    item12.Description = 'this is a description';
    item12.ItemPushedFcn = @ActionPerformedCallback;
    cat3.add(item12);
    item13 = GalleryItem('Statistics',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','stats_app_24.png')));
    item13.Tag = 'stats';
    item13.Description = 'this is a description';
    item13.ItemPushedFcn = @ActionPerformedCallback;
    cat3.add(item13);
    item14 = GalleryItem('Test Measurement',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','image','test_app_24.png')));
    item14.Tag = 'test';
    item14.Description = 'this is a description';
    item14.ItemPushedFcn = @ActionPerformedCallback;
    cat3.add(item14);
    % add default favorites
    item1.addToFavorites();
    item2.addToFavorites();
    item6.addToFavorites();
    item11.addToFavorites();
    item12.addToFavorites();
    % create gallery
    gallery = Gallery(popup, 'MaxColumnCount',8);
    gallery.Tag  = 'gallery';
    % section
    section = Section('GALLERY');
    section.Tag = 'section_gallery';
    % column
    col = section.addColumn();
    col.add(gallery);
end

function section = build321Section()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('3-2-1');
    % column 1
    col = section.addColumn;
    col.add(PushButton('Cut',Icon.COPY_16));
    col.add(PushButton('Copy',Icon.CUT_16));
    col.add(PushButton('Paste',Icon.PASTE_16));
    % column 2
    col = section.addColumn;
    col.add(PushButton('Open',Icon.OPEN_16));
    col.add(PushButton('Close',Icon.CLOSE_16));
    % column 3
    col = section.addColumn;
    col.add(PushButton('New',Icon.NEW_24));
end

function section = buildColumnSpanSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('COLUMN SPAN');
    % panel contains two columns
    panel = Panel();
    col1 = panel.addColumn('HorizontalAlignment','right');
    col1.add(Label('X Label:'))
    col1.add(Label('Y Label:'))
    col2 = panel.addColumn();
    col2.add(TextField());
    col2.add(TextField());
    % column
    col = section.addColumn('Width',50);
    col.add(panel)
    col.add(Slider(0,100,50));
end

function section = buildEmptyControlSection()
    import matlab.ui.internal.toolstrip.*
    section = Section('EMPTY ROW');
    col = section.addColumn();
    col.add(Label('Color:'));
    col.add(Label('Size:'));
    col.addEmptyControl();
    col = section.addColumn('Width',80);
    col.add(ComboBox({'Red';'Green';'Blue'}));
    col.add(ComboBox({'Small';'Medium';'Large'}));
    col.add(CheckBox('Wrap as gift'));
end

function section = buildDynamicPopupSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('DYNAMIC POPUP');
    % column 1
    col1 = section.addColumn();
    btn1 = DropDownButton('DropDown #1',Icon.PLAY_24);
    btn1.DynamicPopupFcn = @buildDynamicPopup;
    col1.add(btn1);
    % column 2
    col2 = section.addColumn();
    btn2 = DropDownButton('DropDown #2',Icon.PLAY_24);
    popup = PopupList();
    btn2.Popup = popup;
    item1 = ListItem('This popup list is static.');
    item1.Description = 'this is a description';
    item2 = ListItemWithPopup('this item has a dynamic sub popup list',Icon.MATLAB_16);
    item2.Description = 'this is a description';
    item2.DynamicPopupFcn = @buildDynamicSubPopup;
    popup.add(item1);
    popup.add(item2);
    col2.add(btn2);
end

function section = buildSharingSection()
    import matlab.ui.internal.toolstrip.*
    % section
    section = Section('SHARING CONTROLS');
    % column: split button and listitem
    col = section.addColumn();
    btn = SplitButton('NEW',Icon.NEW_24);
    btn.Description = 'Create new document';
    btn.ButtonPushedFcn = @ActionPerformedCallback;
    col.add(btn);
    popup = PopupList();
    btn.Popup = popup;
    listitem = ListItem();
    popup.add(listitem);
    btn.shareWith(listitem);
    listitem.TextOverride = 'Script';
    listitem.IconOverride = Icon.OPEN_16;
    % column: checkbox and toggle button
    col = section.addColumn();
    btn = ToggleButton('Control1 is shared',Icon.CUT_16);
    btn.SelectionChangedFcn = @PropertyChangedCallback;
    col.add(btn)
    chk = CheckBox();
    btn.shareWith(chk);
    col.add(chk);
    % column: radio buttons and toggle buttons
    grp = ButtonGroup();
    col1 = section.addColumn();
    btn1 = ToggleButton('Control2 is shared',Icon.COPY_16,grp);
    btn2 = ToggleButton('Control3 is shared',Icon.PASTE_16,grp);
    btn1.Selected = true;
    btn1.SelectionChangedFcn = @PropertyChangedCallback;
    btn2.SelectionChangedFcn = @PropertyChangedCallback;
    col1.add(btn1);
    col1.add(btn2);
    col2 = section.addColumn();
    radio1 = RadioButton(grp);
    radio2 = RadioButton(grp);
    btn1.shareWith(radio1);
    btn2.shareWith(radio2);
    col2.add(radio1);
    col2.add(radio2);
end

%% Popups
function popup = buildStaticPopup()
    import matlab.ui.internal.toolstrip.*
    % main list
    popup = PopupList();
    % header
    header = PopupListHeader('This is a header');
    popup.add(header);
    % list item
    item1 = ListItem('Item 1',Icon.UNDO_16,'This is the description');
    item1.Description = 'this is a description';
    item1.ItemPushedFcn = @ActionPerformedCallback;
    popup.add(item1);
    % list item with checkbox
    item2 = ListItemWithCheckBox('Item 2','This is the description');
    item2.Description = 'this is a description';
    item2.SelectionChangedFcn = @PropertyChangedCallback;
    popup.add(item2);
    % separator
    popup.addSeparator();
    % list item with popup
    item3 = ListItemWithPopup('Item 3',Icon.REDO_16,'This is the description');
    item3.Description = 'this is a description';
    popup.add(item3);
    % sub popup
    sub_popup = PopupList();
    item3.Popup = sub_popup;
    sub_item1 = ListItem('Item 4',Icon.OPEN_16,'This is a description');
    sub_item1.Description = 'this is a description';
    sub_item1.ItemPushedFcn = @ActionPerformedCallback;
    sub_popup.add(sub_item1);
    sub_item2 = ListItemWithCheckBox('Item 5','This is a description');
    sub_item2.Description = 'this is a description';
    sub_item2.SelectionChangedFcn = @PropertyChangedCallback;
    sub_popup.add(sub_item2);
    % popup list panel
    panel = PopupListPanel('MaxHeight',100);
    header1 = PopupListHeader('This is another header');
    panel.add(header1);
    item4 = ListItem('Item 6',Icon.UNDO_16,'This is the description');
    item4.Description = 'this is a description';
    item4.ItemPushedFcn = @ActionPerformedCallback;
    panel.add(item4);
    item5 = ListItemWithCheckBox('Item 7','This is the description');
    item5.Description = 'this is a description';
    item5.SelectionChangedFcn = @PropertyChangedCallback;
    panel.add(item5);
    item6 = ListItem('Item 7',Icon.UNDO_16,'This is the description');
    item6.Description = 'this is a description';
    item6.ItemPushedFcn = @ActionPerformedCallback;
    panel.add(item6);
    item7 = ListItemWithCheckBox('Item 8','This is the description');
    item7.Description = 'this is a description';
    item7.SelectionChangedFcn = @PropertyChangedCallback;
    panel.add(item7);
    popup.add(panel);
end

function popup = buildDynamicPopup(~, ~)
    import matlab.ui.internal.toolstrip.*
    popup = PopupList();
    item1 = ListItem('This popup list is dynamic!');
    item1.Description = 'this is a description';
    item2 = ListItem(['Random Number: ',num2str(rand)],Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','matlab.png')));
    item2.Description = 'this is a description';
    item3 = ListItemWithPopup('this item has a sub popup list');
    item3.Description = 'this is a description';
    popup.add(item1);
    popup.add(item2);
    popup.add(item3);
    subpopup = PopupList();
    item3.Popup = subpopup;
    item4 = ListItem('this popup list is static.');
    item4.Description = 'this is a description';
    item5 = ListItem('Simulink',Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','simulink.png')));
    item5.Description = 'this is a description';
    subpopup.add(item4);
    subpopup.add(item5);
end

function subpopup = buildDynamicSubPopup(~, ~)
    import matlab.ui.internal.toolstrip.*
    item1 = ListItem('This popup list is dynamic!');
    item1.Description = 'this is a description';
    item2= ListItem(['Random Number: ',num2str(rand)],Icon(fullfile(matlabroot,'toolbox','matlab','toolstrip','web','simulink.png')));
    item2.Description = 'this is a description';
    subpopup = PopupList();
    subpopup.add(item1);
    subpopup.add(item2);
end

