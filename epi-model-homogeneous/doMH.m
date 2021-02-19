function [samples,proposals,acceptRates,acceptProbs,rejectedSamples] =...
    doMH(simParams,observationParams,observedData,targetParams,saveName)
% This function runs the Metropolis-Hastings algorithm to estimate the
% target parameters, generates a set of samples and saves other info.

% Set params
numReps  = simParams.numReps;
numIters = simParams.numIters;
saveFreq = simParams.saveFreq;
isTarget = [targetParams.isTarget];

% Preallocate array for MH samples
samples      = zeros(numIters+1,length([targetParams.isTarget]));
samples(1,:) = [targetParams.initGuess];

% Get posterior kernel for init guess
logp_x = getLogpost(simParams,observationParams,observedData,...
    targetParams,targetParams.initGuess);

% Set up some data sets
proposals   = zeros(numIters,6);
acceptRates = zeros(numIters,1);
acceptProbs = zeros(numIters,1);
numAccepted = 0;
rejectedSamples = [];               % for storing rejected samples

% Go through MH iterations
for iter = 2:numIters+1
    x = samples(iter-1,:);      % Set current sample
    x_prime = x.*(1-isTarget) + ...
        [targetParams(1).proposalDist(x(1)),...
        targetParams(2).proposalDist(x(2)),...
        targetParams(3).proposalDist(x(3)),...
        targetParams(4).proposalDist(x(4)),...
        targetParams(5).proposalDist(x(5)),...
        targetParams(6).proposalDist(x(6))].*isTarget;
    
    % Jacobians
    logJx = 1.*(1-isTarget) + ...
        [targetParams(1).logJacobian(x(1)),...
        targetParams(2).logJacobian(x(2)),...
        targetParams(3).logJacobian(x(3)),...
        targetParams(4).logJacobian(x(4)),...
        targetParams(5).logJacobian(x(5)),...
        targetParams(6).logJacobian(x(6))].*isTarget;
        
    logJxprime = 1.*(1-isTarget) + ...
        [targetParams(1).logJacobian(x_prime(1)),...
        targetParams(2).logJacobian(x_prime(2)),...
        targetParams(3).logJacobian(x_prime(3)),...
        targetParams(4).logJacobian(x_prime(4)),...
        targetParams(5).logJacobian(x_prime(5)),...
        targetParams(6).logJacobian(x_prime(6))].*isTarget;
    
    % Compute log p(x')
    logp_xprime = getLogpost(simParams,observationParams,observedData,...
    targetParams,x_prime(1),x_prime(2),x_prime(3),x_prime(4),x_prime(5),x_prime(6));
    
    % Compute acceptance prob
    logp_acc = min(0,logp_xprime-logp_x+sum(logJx)-sum(logJxprime));
    
    % Test whether to accept or reject new sample
    U = rand();    
    if log(U) < logp_acc
        samples(iter,:) = x_prime;
        logp_x = logp_xprime;     % save to avoid calling getLogpost
        numAccepted = numAccepted+1;
    else
        samples(iter,:) = x;
        rejectedSamples = [rejectedSamples; x_prime];
    end
    
    % Save data
    proposals(iter-1,:) = x_prime;
    acceptRates(iter-1) = numAccepted/(iter-1);
    acceptProbs(iter)   = logp_acc;
    
    % Save output as we go, every 'saveFreq' iterations
    if mod(iter-1,saveFreq)==0
        save(['Results/',saveName,'_iter',num2str(iter-1),'.mat'],...
            'simParams','targetParams','numReps','numIters',...
            'samples','proposals','acceptRates',...
            'acceptProbs','rejectedSamples')
    end
end

end

