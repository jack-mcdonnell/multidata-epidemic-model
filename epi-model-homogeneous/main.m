
% This is the main script that calls all functions to generate synthetic 
% data, run epidemic simulation, and do Metropolis-Hastings algorithm.

% Prepare workspace
clear; clc
rng(123)            % seed random number generator
% parpool(2);       % for parallel computing
% profile on        % for diagnosing run time

% Load input parameters
[simParams,transmissionParams,observationParams,priorParams] = setParams();

% Collect observed data
% load transmission params
alpha = transmissionParams.alpha;
beta  = transmissionParams.beta;
sigma = transmissionParams.sigma;
gamma = transmissionParams.gamma;
p_is  = transmissionParams.p_is;
p_sh  = transmissionParams.p_sh;

% simulate epidemic over numDays
tic
[T,SEEIIHRR] = runEpidemic_tau(simParams,alpha,beta,sigma,gamma,p_is,p_sh);
toc
plotSEEIIHRR(simParams,T,SEEIIHRR)

% Collect data
observedData = collectData(simParams,observationParams,SEEIIHRR);
plotData(simParams,observedData)

% Parameter Inference
% Make struct with all info for each target param
targetParams = getTargetParams(transmissionParams,priorParams);

% name for results file
saveName = ['Results_',num2str(sum([targetParams.isTarget])),'params_',...
    num2str(simParams.numReps),'reps_',num2str(simParams.numIters),'iters'];

% Run Metropolis-Hastings algorithm
tic
[samples,proposals,acceptRates,acceptProbs,rejectedSamples] = ...
    doMH(simParams,observationParams,observedData,targetParams,saveName);
runTime = toc;

% Save data to mat file
numReps = simParams.numReps;
numIters = simParams.numIters;
save([simParams.resultsFolder,'/',saveName,'.mat'],...
    'simParams','targetParams','numReps','numIters',...
    'T','SEEIIHRR','observedData',...
    'samples','proposals','acceptRates','acceptProbs',...
    'rejectedSamples','runTime')

% profile viewer
