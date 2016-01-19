function Interface()

    fh = figure('ToolBar','none','Name','Organotypic Invasion Scoring','NumberTitle','off','MenuBar','none');
    
    pos = get(fh,'Position');
    pos(3:4) = [400,600];
    set(fh,'Position',pos);
    
    
    layout = uiextras.HBox('Parent',fh);
    
    blayout = uiextras.VBox('Parent', layout, 'Spacing', 10,'Padding', 20);
    %ax = axes('Parent', layout);
    %set(layout, 'Sizes', [200 -1]);
    
    AddButton('Extract Image from Slides...', @SlideExtractor);
    AddButton('Generate Montages...', @GenerateMontage);
    AddButton('Identify Cells in Images...', @CellClicker); 
    AddButton('Quantify Invasions...', @() CountEmBaby(@ProcessCells));
    AddButton('Quantify Positive/Negative...', @() CountEmBaby(@ProcessPositiveNegativeCells));
    AddButton('Automatically Quantify Invasions...', @() CountDAB(@ProcessDAB));
    AddButton('Automatically Quantify Positive/Negative...', @() CountDAB(@ProcessDABPositiveNegative));
    
    sizes = 50 * ones(1,length(blayout.Children));
    uiextras.Empty('Parent', blayout);
    set(blayout, 'Sizes', [sizes -1]);
    
    function AddButton(name, callback)
        uicontrol('Style','PushButton','String',name,'Parent',blayout,'Callback',@(~,~) CallbackWrapper(callback));
    end

    function CallbackWrapper(callback)
       
        if isdeployed
            try 
                callback();
            catch e
                errordlg([e.stack(1).file ', line ' num2str(e.stack(1).line)],e.message);
            end
        else
            callback();
        end
        
    end

end