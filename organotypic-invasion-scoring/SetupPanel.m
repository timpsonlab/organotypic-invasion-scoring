function [f,ax] = SetupPanel(option_names,option_defaults,option_callback,button_names,button_callback)

    addpath('layout');

    f = figure;
    
    if ~iscell(option_defaults)
        option_defaults = num2cell(option_defaults);
    end
    
    option_names = cellfun(@matlab.lang.makeValidName, option_names, 'UniformOutput', false);
    n_options = length(option_names);
    n_buttons = length(button_names);
    
    options = struct();
    

    layout = uix.HBox('Parent', f);
    left_panel = uix.VBox('Parent', layout, 'Spacing', 4);
    grid = uix.Grid('Parent', left_panel, 'Spacing', 4, 'Padding', 4);

    ax = axes('Parent', layout);
    
    for i=1:n_options
        uicontrol('Style','text','String',option_names{i},'Parent',grid);
    end
    for i=1:n_options
        if islogical(option_defaults{i})
            options.(option_names{i}) = option_defaults{i};
            jhSpinner{i} = uicontrol('Style','popupmenu','Parent',grid,'String',{'No','Yes'},'Callback',@(~,~) edit_callback(i));
        else
            options.(option_names{i}) = option_defaults{i};

            jModel = javax.swing.SpinnerNumberModel(option_defaults{i},0,10000,1);
            jSpinner = javax.swing.JSpinner(jModel);
            jhSpinner{i} = javacomponent(jSpinner, [0,0,80,20], grid);
            set(jhSpinner{i},'StateChangedCallback', @(~,~) edit_callback(i));
        end
    end
    
    option_callback(options);
    
    for i=1:n_buttons
        uicontrol('Style','pushbutton','String',button_names{i},...
                  'Parent',left_panel,'Callback',@(~,~) button_callback(button_names{i}));
    end
    uix.Empty('Parent',left_panel);

    if (n_options > 0)
        grid.Widths = [-1,-1];
        grid.Heights = 22*ones(1,n_options);
    end
    layout.Widths = [150, -1];
    left_panel.Heights = [30*n_options, 30*ones(1,n_buttons) -1];
    
    function edit_callback(option)
        if islogical(option_defaults{option})
            value = logical(jhSpinner{option}.Value - 1);
        else
            value = jhSpinner{option}.Value;
        end
        options.(option_names{option}) = value;
        option_callback(options);
    end

end