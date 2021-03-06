function CellClicker
        
    folder = [];
    files = [];
    im = [];
    only_top_half = false;
    use_deconvolution = false;

    cell_types = {'Top Positive', 'Top Negative', 'Invasive Positive', 'Invasive Negative'};
    cell_colours = {[55,126,184]/255,[228,26,28]/255,[77,175,74]/255,[152,78,163]/255}; % from colorbrewer
    mpp = 0.4971; % default if not saved in file
    
    [fh,ax] = SetupPanel({},[],@OptionCallback,...
    [{'Select Folder...','Select Border','Clear Cells','Undo Click'} cell_types {'<<','>>','Show All','Zoom Top','Color:Normal','Color:Deconvolved'}],@ButtonCallback);
    
    
    mode = '';
    stored_mode = '';
    
    set(fh, 'WindowButtonDownFcn', @MouseDown);
    set(fh, 'WindowKeyPressFcn', @KeyPress);
    set(fh, 'WindowKeyReleaseFcn', @KeyRelease);
    set(fh, 'Pointer', 'crosshair', 'NumberTitle', 'Off');
   
    border_p = [];
    cells_p = {};
    idx = 1;
    mask_im = [];
    options = [];
    undo = [];
    
    border_line = line(0,0,'Marker','x','Color','m');
    
    for j=1:length(cell_types)
        cell_line(j) = line(0,0,'Marker','*','MarkerSize',7,'Color',cell_colours{j},'LineStyle','none');
    end
    
    SelectFolder();
    
    function SelectFolder()
        folder = GetFolderWithMemory();
        folder = [folder filesep];
        files = dir([folder '*.tif']);
        
        names = {files.name};
        names = sort_nat(names);
        sel = cellfun(@(f) (f(1)~='.'), names);
        files = files(sel);
        
        idx = 1;
        OpenFile();
    end
    
    function OpenFile()
       
        filename = [folder files(idx).name];
        im = imread(filename);
        info = imfinfo(filename);
        
        if use_deconvolution
            im = HEDDeconvolution(im);
        end

        xresolution = info.XResolution;
        if xresolution ~= 72 
            mpp = 1/(1e-4 * xresolution);
        end
        
        imshow(im,'Parent',ax);
        hold on;
        sz = size(im);
        c = zeros(sz);
        c(:,:,3) = 1;
        alpha = zeros(sz(1:2));
        mask_im = image(c,'AlphaData',alpha);
        hold off;
        daspect([1 1 1]);
        
        if only_top_half
            ylim([1 sz(1)/2])
        end
        
        border_p = [];
        cells_p = {};
        
        border_line = line(0,0,'Marker','.','Color','m','Parent',ax);
        
        for i=1:length(cell_types)
            cell_line(i) = line(0,0,'Marker','*','MarkerSize',6,'Color',cell_colours{i},'LineStyle','none','Parent',ax);
            cells_p{i} = [];
        end
        
        set(fh, 'Name', ['(' num2str(idx) '/' num2str(length(files)) ') ' files(idx).name]);
        
        Load();
        UpdateLines();
        
    end

    function Save()
       
        if isempty(border_p) && all(cellfun(@isempty,cells_p))
            return
        end
        
        filename = [folder files(idx).name];
        filename = strrep(filename, '.tif', '-seg.mat');
        save(filename,'border_p','cells_p','mpp','undo');
        
    end

    function Load()
        
        filename = [folder files(idx).name];
        filename = strrep(filename, '.tif', '-seg.mat');
        if exist(filename,'file')
            r = load(filename);
            if isfield(r,'top_p')
                border_p = r.top_p;
            else
                border_p = r.border_p;
            end
            cells_p = r.cells_p;
            if ~iscell(cells_p)
                cells_p = {r.top_cells_p, [], r.cells_p, []};
            end
            if isfield(r,'undo')
                undo = r.undo;
            end
        end
        
        
    end

    function OptionCallback(new_options)
        
        if ~isempty(im)
            options = new_options;
            sm = 1-min(im,[],3)/255;
            thresh = options.Thresh1 / 100;
            alpha = sm > thresh;
            set(mask_im,'AlphaData',alpha);
        end
        
    end

    function KeyPress(~,evt)
        pan(fh,'off');
        zoom(fh,'off');
        switch evt.Key
            case 'space'
                pan(fh,'on');
                stored_mode = mode;
                kludge();
            case 'z'
                zoom(fh,'on');
                kludge();
            case 'x'
                zoom(fh,'out');
                kludge();
            case 'c'
                mode = 'Invasive Positive';
                set(fh, 'Pointer', 'crosshair');
            case 'v'
                mode = 'Invasive Negative';
                set(fh, 'Pointer', 'crosshair');
            case 't'
                mode = 'Top Positive';
                set(fh, 'Pointer', 'crosshair');
            case 'y'
                mode = 'Top Negative';
                set(fh, 'Pointer', 'crosshair');
            case 'b'
                mode = 'Select Border';
                set(fh, 'Pointer', 'crosshair');
            case 'rightarrow'
                Save();
                idx = mod(idx,length(files))+1;
                OpenFile();
            case 'leftarrow'
                Save();
                idx = mod(idx-2,length(files))+1;
                OpenFile();
                
        end

        function kludge()
                hManager = uigetmodemanager(fh);  
            for i=1:length(hManager.WindowListenerHandles)
                hManager.WindowListenerHandles(i).Enabled = false;
            end
            set(fh,'KeyPressFcn',@KeyPress);
        end
    end


    function KeyRelease(~,evt)
        %{
        switch evt.Key
            case 'v'
                pan(fh,'off');
                mode = stored_mode; 
                set(fh, 'Pointer', 'crosshair');
                disp(mode)
        end
        %}
    end

    function ButtonCallback(button)
        disp(button);
        switch button
            case 'Select Border'
                border_p = [];
                mode = button;
            case 'Select Folder...'
                SelectFolder();
            case 'Clear Cells' 
                cells_p = {[],[],[],[]};
            case '>>'
                Save();
                idx = mod(idx,length(files))+1;
                OpenFile();
            case '<<'
                Save();
                idx = mod(idx-2,length(files))+1;
                OpenFile();
            case 'Zoom Top'
                only_top_half = true;
                Save();
                OpenFile();
            case 'Show All'
                only_top_half = false;
                Save();
                OpenFile();
            case 'Undo Click'
                if ~isempty(undo)
                    u = undo(end);
                    undo = undo(1:end-1);
                    if ~isnan(u)
                        cells_p{u} = cells_p{u}(1:end-1,:);
                    else
                        border_p = border_p(1:end-1,:);
                    end
                end
                UpdateLines();     
            case 'Color:Normal'
                use_deconvolution = false;
                Save();
                OpenFile();
            case 'Color:Deconvolved'
                use_deconvolution = true;
                Save();
                OpenFile();
            otherwise
                mode = button;
        
        end
        UpdateLines();
    end

    function MouseDown(~,~)
        [x,y] = GetCurrentPoint();
        
        for i=1:length(cell_types)
            if strcmp(mode, cell_types{i})
                cells_p{i}(end+1,:) = [x,y];
                undo(end+1) = i;
            end
        end
        
        switch mode
            case 'Select Border'
                border_p(end+1,:) = [x,y];
                undo(end+1) = nan;
        end
        UpdateLines();
    end

    function UpdateLines()
        if ~isempty(border_p)
            set(border_line,'XData',border_p(:,1),'YData',border_p(:,2));
        else
            set(border_line,'XData',0,'YData',0);
        end
        for i=1:length(cell_types)
            if ~isempty(cells_p{i})
                set(cell_line(i),'XData',cells_p{i}(:,1),'YData',cells_p{i}(:,2));
            else
                set(cell_line(i),'XData',0,'YData',0);
            end
        end
    end

    function [x,y] = GetCurrentPoint()
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2); 
    end

    

end