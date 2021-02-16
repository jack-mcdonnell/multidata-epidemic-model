function plotInference(figsFolder,targetParams,burnIn,maxIter,...
    proposals,samples,sampleMeans,rejectedSamples,acceptRates)
% This function generates the plots from the MH process.

% Plot MH samples and posterior dists for each param
plotSamples(targetParams,proposals,samples,sampleMeans,burnIn,maxIter,figsFolder)

% Plot distributions of rejected samples
plotDistributionRejectedSamples(targetParams,rejectedSamples,burnIn,figsFolder)

% Plot acceptance rates
plotAcceptanceRates(burnIn,maxIter,acceptRates,figsFolder)


end


function plotSamples(targetParams,proposals,samples,sampleMeans,burnIn,maxIter,figsFolder)
% Plot MH samples and posterior dists for each param

numTargetParams = sum([targetParams.isTarget]);

% For prior dists
supp1 = 0:0.01:4;       % two supports for convenience
supp2 = 0:0.01:1;

% Set up figure (for all subplots in one fig)
figure('Position', [250 250 900 1200])
set(gcf, 'color','w')
fs = 14;
interp = 'latex';

% for paramNum=find([targetParams.isTarget])
for paramNum=1:6
    if paramNum<5
        supp = supp1;
    else
        supp = supp2;
    end
    
    subplot_1 = subplot(6,2,2*(paramNum-1)+1);
    hold on
    plot(burnIn+1:maxIter,proposals(burnIn:maxIter-1,paramNum),'-','color',rgb("Gray"),...
    'MarkerSize',10,'linewidth',1,'DisplayName','Proposals');
    plot(burnIn:maxIter,samples(burnIn:maxIter,paramNum),'-','color','blue',...
        'MarkerSize',12,'linewidth',1,'DisplayName','Samples');
    plot([burnIn,maxIter],...
        [targetParams(paramNum).trueVal,targetParams(paramNum).trueVal],...
        '--','color',rgb('Red'),'linewidth',2,'DisplayName','True value')
%     plot(burnIn+1:numIters,runningMean(:,paramNum),...
%         '-','color','red','linewidth',2,'DisplayName','Mean')
    hold off    
    if paramNum==numTargetParams
        xlabel('Iterations','FontSize',fs+2,'interpreter','latex')
    end
    ylabel(['$',targetParams(paramNum).label,'$'],...
        'interpreter',interp,'FontSize',fs+2)
%     yh = get(gca,'ylabel'); % handle to the label object
%     p = get(yh,'position'); % get the current position property
%     p(1) = 1.5*p(1);
%     set(yh,'position',p);
    scaleLength = 0.8;    % 0.8;
    subplot1_length = scaleLength*subplot_1.Position(3);
    if paramNum==1
        leg1 = legend('boxoff');
        set(leg1,'Location', 'NorthEastOutside');
    end
    
    if paramNum < numTargetParams
       xticklabels([])
    end
    subplot_1.Position(3) = subplot1_length;
    leg1_length = leg1.Position(3);
    xlim([burnIn,maxIter])
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
    
    
    subplot_2 = subplot(6,2,2*(paramNum-1)+2);
    hold on
    plot(supp,targetParams(paramNum).prior(supp),'--k',...
        'linewidth',1,'DisplayName','Prior')
    histogram(samples(burnIn:maxIter,paramNum),...
        'normalization','pdf','edgecolor','None','DisplayName','Posterior')
%     plot(targetParams(paramNum).trueVal,0,'.r','markersize',30,...
%         'DisplayName','True value')
    scatter(targetParams(paramNum).trueVal,0,100,...
        'MarkerFaceColor','r','MarkerEdgeColor','None',...
        'DisplayName','True value');
%     plot(runningMean(end,paramNum),0,'.b','markersize',30,...
%         'DisplayName','Estimate')
    estPoint = scatter(sampleMeans(paramNum),0,100,...
        'MarkerFaceColor','b','MarkerEdgeColor','None',...
        'DisplayName','Estimate');
    estPoint.MarkerFaceAlpha = .5;
    hold off
%     xlim([0,max(supp)])
    if paramNum <=2
        xlim([0,2])
    elseif paramNum <= 4
        xlim([0,1])
    elseif paramNum == 5
        xlim([0.6,1.0])
%         xlim([0,1])
    else
        xlim([0.005,0.02])
%         xlim([0,1])
    end
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
    xlabel(['$',targetParams(paramNum).label,'$'],...
        'interpreter', interp,'FontSize',fs+2)
%     ylabel('Probability density','FontSize',fontSize+2)
    if paramNum==1
        leg2 = legend('boxoff');
        set(leg2,'Location', 'NorthEastOutside');
        leg2.Position(1) = 1.05*leg2.Position(1);
        leg2.Position(3) = leg1_length;
    end
    subplot_2.Position(3) = subplot1_length;
end

plotName = 'MHresults';
figTitle = [plotName,'.png'];
saveas(gcf, [figsFolder,'/',figTitle])

end


function plotDistributionRejectedSamples(targetParams,rejectedSamples,burnIn,figsFolder)
% Plot distribution of rejected samples

fs = 14;
interp = 'latex';

figure('Position', [250 250 900 1000])
set(gcf, 'color','w')

for paramNum=1:6
    
    subplot(3,2,paramNum)
    
    hold on
    paramName = targetParams(paramNum).label;
    histogram(rejectedSamples(burnIn:end,paramNum),'edgecolor','None','DisplayName',paramName)
    xlabel(['$',targetParams(paramNum).label,'$'],...
        'interpreter', interp,'FontSize',fs+2)
    
    if mod(paramNum,2)==1
        ylabel('Number of samples',...
            'interpreter', interp,'FontSize',fs+2)
    end
    hold off
    
    set(gca,'FontSize',fs,'TickLabelInterpreter','latex')
    
end

plotName = 'rejectedDistributions';
figTitle = [plotName, '.png'];
saveas(gcf, [figsFolder,'/',figTitle])
end


function plotAcceptanceRates(burnIn, maxIter,acceptRates,figsFolder)
% Plot acceptance rates
fs = 16;
interp = 'latex';

figure('Position', [250 250 700 500])
set(gcf, 'color','w')
    
hold on
plot(burnIn:maxIter,acceptRates(burnIn:maxIter))
xlabel('Iterations',...
    'interpreter', interp,'FontSize',fs)
ylabel('Acceptance rate','interpreter', interp,'FontSize',fs)

hold off

set(gca,'FontSize',fs,'TickLabelInterpreter','latex')

plotName = 'acceptanceRates';
figTitle = [plotName, '.png'];
saveas(gcf, [figsFolder,'/',figTitle])
end


