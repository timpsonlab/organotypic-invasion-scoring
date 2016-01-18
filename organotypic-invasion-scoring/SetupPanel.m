function [f,ax] = SetupPanel(option_names,option_defaults,option_callback,button_names,button_callback)

    f = figure;

    %option_names = {'Width', 'Height'};
    %option_defaults = [10, 10];
    
    
    option_names = cellfun(@matlab.lang.makeValidName, option_names, 'UniformOutput', false);
    n_options = length(option_names);
    n_buttons = length(button_names);
    
    options = struct();
    

    layout = uiextras.HBox('Parent', f);
    left_panel = uiextras.VBox('Parent', layout, 'Spacing', 4);
    grid = uiextras.Grid('Parent', left_panel, 'Spacing', 4, 'Padding', 4);

    ax = axes('Parent', layout);
    
    for i=1:n_options
        uicontrol('Style','text','String',option_names{i},'Parent',grid);
    end
    for i=1:n_options
        options.(option_names{i}) = option_defaults(i);
        
        jModel = javax.swing.SpinnerNumberModel(option_defaults(i),0,1000,1);
        jSpinner = javax.swing.JSpinner(jModel);
        jhSpinner(i) = javacomponent(jSpinner, [0,0,80,20], grid);
        set(jhSpinner(i),'StateChangedCallback', @(~,~) edit_callback(i));
    end
    
    option_callback(options);
    
    for i=1:n_buttons
        uicontrol('Style','pushbutton','String',button_names{i},...
                  'Parent',left_panel,'Callback',@(~,~) button_callback(button_names{i}));
    end
    uiextras.Empty('Parent',left_panel);

    if (n_options > 0)
        set(grid, 'ColumnSizes', [-1,-1], 'RowSizes', 22*ones(1,n_options));
    end
    set(layout,'Sizes',[120, -1])
    set(left_panel,'Sizes',[30*n_options, 30*ones(1,n_buttons) -1]);
    
    function edit_callback(option)
        value = jhSpinner(option).Value;
        options.(option_names{option}) = value;
        option_callback(options);
    end

end