function plotData(figsFolder,observedData)

% Get observed data
I_p        = observedData.I_true;
H_p        = observedData.H_true;
Rs_G       = observedData.Rs_G;
Rc_G       = observedData.Rc_G;
Rpos_G     = observedData.Rpos_G;
Rs_H       = observedData.Rs_H;
Rc_H       = observedData.Rc_H;
Rpos_H     = observedData.Rpos_H;
H_FC       = observedData.H_FC;
H_FCandFT  = observedData.H_FCandFT;
H_FClessFT = H_FC-H_FCandFT;
C          = observedData.C;
C_uniqueGP = observedData.C_uniqueGP;
C_uniqueH  = C-C_uniqueGP; 


% Plots
fs = 12;
figure('Position', [250 250 600 1500])
set(gcf, 'color','w')

subplot(3,2,1)
hold on
% plot(I_p,'color',rgb("Grey"),'linewidth',lw)
areaI_p = area(I_p,'EdgeColor','None');
areaI_p.FaceColor = rgb('Silver');
hold off
title('$I^p$','interpreter','latex')
set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
xlim([1,14])
xticklabels([])

subplot(3,2,2)
hold on
% plot(H_p,'color',rgb("Grey"),'linewidth',lw)
areaH_p = area(H_p,'EdgeColor','None');
areaH_p.FaceColor = rgb('Silver');
hold off
title('$H^p$','interpreter','latex')
set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
xlim([1,14])
xticklabels([])

subplot(3,2,3)
hold on
% plot(Rs_G,'linewidth',lw,'displayname','$R_s^G$')
% plot(Rc_G,'linewidth',lw,'displayname','$R_c^G$')
% plot(Rpos_G,'linewidth',lw,'displayname','$R_+^G$')
areaFTGP=area([Rs_G,Rc_G,Rpos_G],'EdgeColor','None');
set(areaFTGP, {'DisplayName'}, {'$R_s^G$';'$R_c^G$';'$R_+^G$'});
areaFTGP(1).FaceColor = rgb('Blue');
areaFTGP(2).FaceColor = rgb('Red');
areaFTGP(3).FaceColor = rgb('Green');
areaFTGP(1).FaceAlpha = 0.5;
areaFTGP(2).FaceAlpha = 0.5;
areaFTGP(3).FaceAlpha = 0.5;
hold off
title("FluTracking (GP)",'interpreter','latex')
leg3=legend('boxoff');
set(leg3,'interpreter','latex','Location','northeast');
set(gca,'FontSize',fs)
xlim([1,14])
xticklabels([])

subplot(3,2,4)
hold on
% plot(Rs_H,'-','linewidth',lw,'displayname','$R_s^H$')
% plot(Rc_H,'-','linewidth',lw,'displayname','$R_c^H$')
% plot(Rpos_H,'-','linewidth',lw,'displayname','$R_+^H$')
areaFTH=area([Rs_H,Rc_H,Rpos_H],'EdgeColor','None');
set(areaFTH, {'DisplayName'}, {'$R_s^H$';'$R_c^H$';'$R_+^H$'});
areaFTH(1).FaceColor = rgb('Blue');
areaFTH(2).FaceColor = rgb('Red');
areaFTH(3).FaceColor = rgb('Green');
areaFTH(1).FaceAlpha = 0.5;
areaFTH(2).FaceAlpha = 0.5;
areaFTH(3).FaceAlpha = 0.5;
hold off
title("FluTracking (H)",'interpreter','latex')
leg4=legend('boxoff');
set(leg4,'interpreter','latex','Location','northeast');
set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
xlim([1,14])
xticklabels([])

subplot(3,2,5)
hold on
% plot(H_FC,'color',rgb('DeepPink'),'linewidth',lw,'displayname','$H^{FC}$')
% plot(H_FCandFT,'--b','linewidth',lw,'displayname','$H^{FC\cap FT}$')
% plot(H_FClessFT,'--r','linewidth',lw,'displayname','$H^{FC\setminus FT}$')
% bar(H_FC,'EdgeColor','b','displayname','$H^{FC}$')
% b1 = bar([H_FClessFT,H_FCandFT],'stacked','EdgeColor','None');
% set(b1, {'DisplayName'}, {'$H^{FC\cap FT}$'; '$H^{FC\setminus FT}$'});
areaFC=area([H_FClessFT,H_FCandFT],'EdgeColor','None');
set(areaFC, {'DisplayName'}, {'$H^{FC\setminus FT}$';'$H^{FC\cap FT}$'});
areaFC(1).FaceColor = rgb('Blue');
areaFC(2).FaceColor = rgb('Red');
areaFC(1).FaceAlpha = 0.5;
areaFC(2).FaceAlpha = 0.5;
hold off
title("FluCAN",'interpreter','latex')
leg5=legend('boxoff');
set(leg5,'interpreter','latex','Location','northeast');
set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
xlabel('Time (weeks)','interpreter','latex')
xlim([1,14])

subplot(3,2,6)
hold on
% plot(C_uniqueGP,'--','linewidth',lw,'displayname','$C^{GP^*}$')
% plot(C_uniqueH,'--','linewidth',lw,'displayname','$C^{H^*}$')

% bar(C,'displayname','$C$')
% b2 = bar([C_uniqueGP,C_uniqueH,Rpos_G,Rpos_H,H_FClessFT],...
%     'stacked','EdgeColor','None');
% set(b2, {'DisplayName'}, {'$C^{GP^*}$';'$C^{H^*}$';'$R_+^G$';'$R_+^H$';...
%     '$H^{FC\cap FT}$'});
areaC=area([C_uniqueGP,C_uniqueH,Rpos_G,Rpos_H,H_FClessFT],'EdgeColor','None');
set(areaC, {'DisplayName'}, {'$C^{GP^*}$';'$C^{H^*}$';'$R_+^G$';'$R_+^H$';...
    '$H^{FC\cap FT}$'});
areaC(1).FaceColor = rgb('Blue');
areaC(2).FaceColor = rgb('Red');
areaC(3).FaceColor = rgb('Green');
areaC(4).FaceColor = rgb('Gold');
areaC(5).FaceColor = rgb('Violet');
areaC(1).FaceAlpha = 0.5;
areaC(2).FaceAlpha = 0.5;
areaC(3).FaceAlpha = 0.5;
areaC(4).FaceAlpha = 0.5;
areaC(5).FaceAlpha = 0.5;
% plot(C,'color',rgb('DeepPink'),'linewidth',lw,'displayname','$C$')
hold off
title("Case notifications",'interpreter','latex')
leg6=legend('boxoff');
set(leg6,'interpreter','latex','Location','northeast');
set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
xlabel('Time (weeks)','interpreter','latex')
xlim([1,14])

saveas(gcf, [figsFolder, 'allDataPlot.png'])

