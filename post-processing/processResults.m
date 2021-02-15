
% This script loads the results from the MH run, computes the parameters
% estimates, and prints/plots the results

% Set MH params
numTargetParams = 6;
numReps         = 100;           % num pseudomarginal reps
numIters        = 1000;         % num MH iters

partialResults  = 0;            % choose partial=1
maxIter         = 300;          % largest iteration for partial results
burnIn          = 1;           % must be less than numIters

% Load data
resultsFolder = 'Results';
saveName = ['Results_',num2str(numTargetParams),'params_',...
    num2str(numReps),'reps_',num2str(numIters),'iters'];
if partialResults==1
    saveName = [saveName,'_iter',num2str(maxIter)];
end

resultsData = load([resultsFolder,'/',saveName,'.mat']);

% Recover data
simParams    = resultsData.simParams;
targetParams = resultsData.targetParams;
% observedData = resultsData.observedData;
numIters     = resultsData.numIters;
numReps      = resultsData.numReps;
% runTime      = resultsData.runTime;
samples      = resultsData.samples;
proposals    = resultsData.proposals;
acceptRates  = resultsData.acceptRates;
acceptProbs  = resultsData.acceptProbs;
rejectedSamples = resultsData.rejected;
if partialResults == 0
    observedData = resultsData.observedData;
    runTime      = resultsData.runTime;
end

isTarget = [targetParams.isTarget];     % indicates which params we want

% Present results
% True epidemic spread
% plotSEEIIHRR(simParams.hh,T,SEEIIHRR)

% Summary stats to estimate params from samples
runningMean = cumsum(samples(burnIn+1:maxIter,:))./(1:(maxIter-burnIn))';
sampleMeans = runningMean(maxIter-burnIn,:);
variances   = var(samples(burnIn+1:maxIter,:));
stdevs      = sqrt(variances);

% print estimates
fprintf(' \n')
fprintf('Estimates:\n')
fprintf(['alpha = ',num2str(round(sampleMeans(1),4)),'\n'])
fprintf(['beta  = ',num2str(round(sampleMeans(2),4)),'\n'])
fprintf(['sigma = ',num2str(round(sampleMeans(3),4)),'\n'])
fprintf(['gamma = ',num2str(round(sampleMeans(4),4)),'\n'])
fprintf(['p_is  = ',num2str(round(sampleMeans(5),4)),'\n'])
fprintf(['p_sh  = ',num2str(round(sampleMeans(6),4)),'\n'])

% Plot samples and estimates
plotInference(simParams.figsFolder,targetParams,burnIn,maxIter,...
    proposals,samples,sampleMeans,rejectedSamples,acceptRates)

