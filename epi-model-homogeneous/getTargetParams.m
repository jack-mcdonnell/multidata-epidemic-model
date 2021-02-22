function targetParams = getTargetParams(transmissionParams,priorParams)
% This function takes the inputs for the priors and sets up a struct for
% each target parameter, including name, true value, initial guess etc.

alpha = transmissionParams.alpha;
beta  = transmissionParams.beta;
sigma = transmissionParams.sigma;
gamma = transmissionParams.gamma;
p_is  = transmissionParams.p_is;
p_sh  = transmissionParams.p_sh;

inferAlpha = priorParams.inferAlpha;
inferBeta  = priorParams.inferBeta;
inferSigma = priorParams.inferSigma;
inferGamma = priorParams.inferGamma;
inferPis   = priorParams.inferPis;
inferPsh   = priorParams.inferPsh;

alpha0 = priorParams.alpha0;
beta0  = priorParams.beta0;
sigma0 = priorParams.sigma0;
gamma0 = priorParams.gamma0;
pis0   = priorParams.pis0;
psh0   = priorParams.psh0;

a1 = priorParams.a1;
b1 = priorParams.b1;
a2 = priorParams.a2;
b2 = priorParams.b2;
a3 = priorParams.a3;
b3 = priorParams.b3;
a4 = priorParams.a4;
b4 = priorParams.b4;

% define prior distributions for alpha, beta, sigma, gamma, pis, psh
if inferAlpha == 1
    alphaPrior = @(alpha) gampdf(alpha,a1,1/b1);
else
    alpha0 = alpha;
    alphaPrior = @(alpha) 1;
end

if inferBeta == 1
    betaPrior = @(beta) gampdf(beta,a2,1/b2);
else
    beta0 = beta;
    betaPrior = @(beta) 1;
end

if inferSigma == 1
    sigmaPrior = @(sigma) gampdf(sigma,a3,1/b3);
else
    sigma0 = sigma;
    sigmaPrior = @(sigma) 1;
end

if inferGamma == 1
    gammaPrior = @(gamma) gampdf(gamma,a4,1/b4);
else
    gamma0 = gamma;
    gammaPrior = @(gamma) 1;
end

if inferPis == 1
    c1 = 1;
    d1 = 1;
    pisPrior = @(pis) betapdf(pis,c1,d1);
else
    pis0 = p_is;
    pisPrior = @(pis) 1;
end

if inferPsh == 1
    c2 = 1;
    d2 = 1;
    pshPrior = @(psh) betapdf(psh,c2,d2);
else
    psh0 = p_sh;
    pshPrior = @(psh) 1;
end


% define proposal distributions
logit = @(x) log(x)-log(1-x);
expit = @(x) exp(x)./(1+exp(x));
s = [.1 .1 .1 .1 .1 .1];            % std devs for normal proposals

alphaProposalDist = @(x) exp(log(x) + normrnd(0,s(1)));
betaProposalDist  = @(x) exp(log(x) + normrnd(0,s(2)));
sigmaProposalDist = @(x) exp(log(x) + normrnd(0,s(3)));
gammaProposalDist = @(x) exp(log(x) + normrnd(0,s(4)));
pisProposalDist   = @(x) expit(logit(x) + normrnd(0,s(5)));
pshProposalDist   = @(x) expit(logit(x) + normrnd(0,s(6)));

% set logJacobian
alphaLogJacobian = @(x) -log(x);
betaLogJacobian  = @(x) -log(x);
sigmaLogJacobian = @(x) -log(x);
gammaLogJacobian = @(x) -log(x);
pisLogJacobian   = @(x) -(log(x)+log(1-x));
pshLogJacobian   = @(x) -(log(x)+log(1-x));

% combine all info in struct
alphaStruc = struct('name','alpha','label','\alpha','trueVal',alpha,...
    'isTarget',inferAlpha,'initGuess',alpha0,'prior',alphaPrior,...
    'proposalDist',alphaProposalDist,'logJacobian',alphaLogJacobian);

betaStruc = struct('name','beta','label','\beta','trueVal',beta,...
    'isTarget',inferBeta,'initGuess',beta0,'prior',betaPrior,...
    'proposalDist',betaProposalDist,'logJacobian',betaLogJacobian);

sigmaStruc = struct('name','sigma','label','\sigma','trueVal',sigma,...
    'isTarget',inferSigma,'initGuess',sigma0,'prior',sigmaPrior,...
    'proposalDist',sigmaProposalDist,'logJacobian',sigmaLogJacobian);

gammaStruc = struct('name','gamma','label','\gamma','trueVal',gamma,...
    'isTarget',inferGamma,'initGuess',gamma0,'prior',gammaPrior,...
    'proposalDist',gammaProposalDist,'logJacobian',gammaLogJacobian);

pisStruc = struct('name','pis','label','p_{is}','trueVal',p_is,...
    'isTarget',inferPis,'initGuess',pis0,'prior',pisPrior,...
    'proposalDist',pisProposalDist,'logJacobian',pisLogJacobian);

pshStruc = struct('name','psh','label','p_{sh}','trueVal',p_sh,...
    'isTarget',inferPsh,'initGuess',psh0,'prior',pshPrior,...
    'proposalDist',pshProposalDist,'logJacobian',pshLogJacobian);

targetParams =...
    [alphaStruc; betaStruc; sigmaStruc; gammaStruc; pisStruc; pshStruc];


end