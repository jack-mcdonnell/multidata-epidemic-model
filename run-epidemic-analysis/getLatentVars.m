function [I_p, H_p] = getLatentVars(simParams,al,bet,sig,gam,p_is,p_sh)
% This script does numRuns runs of the epidemic model and stores the
% latent data from each run.

numDays  = simParams.numDays;
tau      = simParams.tau;
numReps  = simParams.numReps;
numWeeks = numDays/7;

% Run epidemic sims
epidemicData = zeros(numDays/tau+1,10,numReps);
% tic
for i=1:numReps
% parfor i=1:numReps
    [~, epidemicData(:,:,i)]=...
        runEpidemic_tau(simParams,al,bet,sig,gam,p_is,p_sh);
end
% toc

% Store latent data
I_p = zeros(numWeeks, numReps);
H_p = zeros(numWeeks, numReps);
for i = 1:numReps
    newCasesWeekly = getWeeklyCases(numDays,tau,epidemicData(:,:,i));
    I_p(:,i) = newCasesWeekly(:,1);
    H_p(:,i) = newCasesWeekly(:,2);
end

end