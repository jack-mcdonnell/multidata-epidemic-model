function l = getLoglikelihood(simParams,observationParams,observedData,I_p,H_p)
% This function calculates the log-likelihood by computing the
% pseudomarginal estimate of the expectation of logP(FT,FC,C|I^p, H^p).

numReps = simParams.numReps;

logPdataGivenLatent = zeros(numReps,1);
for s=1:numReps
    logPdataGivenLatent(s) =...
        computeLogPdatagivenlatent(observationParams,observedData,...
        I_p(:,s),H_p(:,s));
end

% Do the average (pseudomarginal estimate)
l = lnsumrecurr(logPdataGivenLatent)-log(numReps);

end