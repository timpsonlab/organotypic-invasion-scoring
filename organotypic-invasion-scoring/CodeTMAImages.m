% Relabel images extracted from TMAs according to correct
% code and cell line

root = uigetdir('','Choose Root Directory');
staining = {'anti-Lox' 'pSrc' 'Src'};

tma = {'TMA#1', 'TMA#2', 'TMA#3'};
%root = '/Volumes/Seagate Backup Plus Drive/Histology Data/TMAs/';
output_folder = 'Montages/';

line_table = readtable([root 'Cell Line Codes.csv']);

rows = {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'};
cols = num2cell(1:12);

pos_names = cellfun(@(a,b) [a num2str(b)], repmat(rows,[1 12]), repmat(cols,[8 1]), 'UniformOutput', false);

for m=1:length(staining)
    for i=1:length(tma)

        codes_file = [root tma{i} ' codes.csv'];
        codes = csvread(codes_file,1,1);

        unique_codes = unique(codes(:));
        unique_codes = unique_codes(unique_codes > 0);

        for j=1:length(unique_codes)

            code = unique_codes(j);

            line = line_table.Line(line_table.Code == code);

            if isempty(line)
                line = '';
            else
                line = [' ' line{1}];
            end

            output = [staining{m} ' ' num2str(code) line]

            sel_pos = pos_names(codes == code);

            im = [];
            for k=1:length(sel_pos)
                filename = [root 'Extracted Images/' staining{m} filesep staining{m} ' ' tma{i} '_' sel_pos{k} '.tif'];

                imi = imread(filename);

                output_file = [root 'Coded Images' filesep staining{m} filesep output '_' num2str(k) '.tif'];
                imwrite(imi, output_file);

                im = [im, imi];
            end

            output_file = [root output_folder staining{m} filesep output '.tif'];
            imwrite(im, output_file)


            imagesc(im); daspect([1 1 1]);
            drawnow


        end

    end
end