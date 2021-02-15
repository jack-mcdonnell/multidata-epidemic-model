function logprior =...
    getLogprior(targetParams,alpha,beta,sigma,gamma,p_is,p_sh)

alphaPrior = targetParams(1).prior(alpha);
betaPrior  = targetParams(2).prior(beta);
sigmaPrior = targetParams(3).prior(sigma);
gammaPrior = targetParams(4).prior(gamma);
pisPrior   = targetParams(5).prior(p_is);
pshPrior   = targetParams(6).prior(p_sh);

% Calculate joint probability
prior = ...
    prod([alphaPrior,betaPrior,sigmaPrior,gammaPrior,pisPrior,pshPrior]);

% Then do log-prior
logprior = log(prior);

end

