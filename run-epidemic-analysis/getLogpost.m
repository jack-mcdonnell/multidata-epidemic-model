function logpost = ...
    getLogpost(simParams,observationParams,observedData,targetParams,...
    alpha,beta,sigma,gamma,p_is,p_sh)
% This function takes in all params and the observed data, computes the log
% likelihood and logprior, then returns logposterior.

% Do many runs of epidemic and generate latent variables
[I_p, H_p] = getLatentVars(simParams,alpha,beta,sigma,gamma,p_is,p_sh);

% Compute loglikelihood
loglike = getLoglikelihood(simParams,observationParams,observedData,...
    I_p,H_p);
% loglike = 0;

% Compute logprior
logprior = getLogprior(targetParams,alpha,beta,sigma,gamma,p_is,p_sh);

% Compute logposterior
logpost = loglike + logprior;

end

