function plotSEEIIHRR(simParams,T,SEEIIHRR)

if simParams.plotEpidemic == 1
    
    figsFolder = simParams.figsFolder;

    % store SEIR time series
    S   = SEEIIHRR(:,1);
    E1  = SEEIIHRR(:,2);
    E2  = SEEIIHRR(:,3);
    I1a = SEEIIHRR(:,4);
    I2a = SEEIIHRR(:,5);  
    I1s = SEEIIHRR(:,6);
    I2s = SEEIIHRR(:,7);
    H   = SEEIIHRR(:,8);
    Ra  = SEEIIHRR(:,9);
    Rs  = SEEIIHRR(:,10);

    nRows = 4;
    nHH   = 1;
    fs    = 16;     % font size
    lw    = 2;      % line width

    figure('Position', [250 250 800 600])
    set(gcf, 'color','w')

    sp1=subplot(nRows,1, 1);
    hold on
    plot(T,S(:,nHH),'-','color',rgb('RoyalBlue'),'linewidth',lw,'DisplayName','$S$');
    hold off
    ylabel('Susceptible','interpreter','latex')
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')

    sp2 = subplot(nRows,1, 2);
    hold on
    plot(T,E1(:,nHH),'-','color',rgb('Gold'),'linewidth',lw,'DisplayName','$E_1$');
    plot(T,E2(:,nHH),'-','color',rgb('DarkOrange'),'linewidth',lw,'DisplayName','$E_2$');
    hold off
    ylabel('Exposed','interpreter','latex');
    leg2 = legend('boxoff');
    set(leg2,'interpreter','latex','Location','NorthEastOutside');
    sp2_length = sp2.Position(3);
    % ylim([0,20e3])
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')

    sp1.Position(3) = sp2_length;   % set length of sp1 above using sp2 length

    sp3=subplot(nRows,1, 3);
    hold on
    plot(T,I1s(:,nHH),'-','linewidth',lw,'color',rgb('Red'),...
        'DisplayName','$I_{1s}$');
    plot(T,I2s(:,nHH),'-','linewidth',lw,'color',rgb('FireBrick'),...
        'DisplayName','$I_{2s}$');
    plot(T,I1a(:,nHH),'-','linewidth',1,'color',rgb('Red'),...
        'DisplayName','$I_{1a}$');
    plot(T,I2a(:,nHH),'-','linewidth',1,'color',rgb('FireBrick'),...
        'DisplayName','$I_{2a}$');
    hold off
    ylabel('Infectious','interpreter','latex');
    leg3 = legend('boxoff');
    set(leg3,'interpreter','latex','Location','NorthEastOutside');
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')

    sp4=subplot(nRows,1, 4);
    hold on
    plot(T,Rs(:,nHH),'-','linewidth',lw,'color',rgb('MediumSeaGreen'),'DisplayName','$R_s$');
    plot(T,Ra(:,nHH),'--','linewidth',lw,'color',rgb('ForestGreen'),'DisplayName','$R_a$');
    plot(T,H(:,nHH),'-','linewidth',lw,'color',rgb('Silver'),'DisplayName','$H$');
    hold off
    xlabel('Time (days)','interpreter','latex');
    ylabel('Recovered','interpreter','latex');
    leg4 = legend('boxoff');
    set(leg4,'interpreter','latex','Location','NorthEastOutside');
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')

    % Save figure
    saveas(gcf, [figsFolder, 'SEEIIHRR_trajectories.png'])
    
end



end