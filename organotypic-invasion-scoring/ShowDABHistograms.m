
legends = {'IgG + DMSO', 'IgG + Das', 'anti-Lox + DMSO', 'anti-Lox + Das'};
legends = [legends legends];


[~,zerop] = min((xx-0).^2); 

figure(1)

set(0,'DefaultAxesFontSize',14)

clf
for i=1:8

    subplot(2,4,i)
    area(xx(2:zerop),depth_F(2:zerop,i),'FaceColor','b')
    hold on;
    area(xx(zerop:end),depth_F(zerop:end,i),'FaceColor','r')

    title(legends{i})
    xlabel('Invasion Depth (px)')
    xlim([-400 1000]);
    ylim([0 1])
   
end