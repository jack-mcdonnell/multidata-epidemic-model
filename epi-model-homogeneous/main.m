
% This is the main script that calls all functions to generate synthetic 
% data, run epidemic simulation, and do Metropolis-Hastings algorithm.

% Prepare workspace
clear; clc
resultsFolder = 'Results';    % '/Users/jackmcdonnell/Documents/Uni/Master/2020/Thesis/TeX/Figs/'
rng(123)            % seed random number generator
% parpool(2);       % for parallel computing
% profile on        % for diagnosing run time

% Inputs
% hh = [ones(1,134827),2*ones(1,166105),3*ones(1,78212),4*ones(1,74578),...
%     5*ones(1,27024),6*ones(1,11703)];   % Adelaide household size distribution from ABS (2016)
% hh       = 1000*ones(1,100); % household structure
hh       = 1e5;
numDays  = 98;              % max number of days in sim
days     = 0:numDays;
tau      = 1/10;        	% time step for tau-leap algorithm
numReps  = 100;             % number of reps for pseudomarginal estimate
numIters = 1000;             % number of iterations for Metropolis-Hastings 
saveFreq = 100;         	% save MH output every saveFreq iterations
informPriors = 1;           % 1=>inform priors, 0=>less inform priors

% Simulation parameters, save in struct
simParams      	      = struct;
simParams.hh          = hh;         % shuffle(hh) to randomise households
simParams.numDays     = numDays;
simParams.days        = days;
simParams.tau         = tau;
simParams.numReps     = numReps;
simParams.numIters    = numIters;
simParams.recordDaily = 0;
simParams.infecInit   = 3;
simParams.saveFreq    = saveFreq;
simParams.figsFolder  = resultsFolder;

% True transmission params ("unknown")
alpha = 0;  %.3;             % transmission rate b/w households
beta  = .5;             % transmission rate w/in/w households
sigma = 1/3;            % 1/sigma = incubation period
gamma = 1/7;            % 1/gamma = infectious period
p_is  = 0.8;            % prob symptoms given infected
p_ih  = 0.01;           % prob hospitalised given infected
p_sh  = p_ih/p_is;      % prob hospitalised given symptoms

% Observation params ("known")
observationParams         = struct;
observationParams.pFT     = 0.01; 	% prop popn enrolled in fluTracking
observationParams.pFC     = 0.4;	% prop hospitals in FluCAN
observationParams.p_GPtest= 0.5;  	% prob sympt person tested by GP
observationParams.p_Htest = 0.8;   	% prob sympt person tested in hospital
observationParams.p_pos   = 0.9;   	% prob test produces true positive
observationParams.ILI_Gnf = 0;  	% prop nonflu ILI present to GP
observationParams.ILI_Hnf = 0;    	% prop nonflu ILI present to Hospital

% Collect observed data
% simulate epidemic over numDays
tic
[T,SEEIIHRR] = runEpidemic_tau(simParams,alpha,beta,sigma,gamma,p_is,p_sh);
toc
% plotSEEIIHRR(simParams.figsFolder,T,SEEIIHRR)   % plot trajectories

% collect data
observedData = collectData(simParams,observationParams,SEEIIHRR);
% plotData(simParams.figsFolder,observedData)


% Parameter Inference
% set which parameters to estimate (0=keep fixed, 1=estimate)
isTargetAlpha = 0;
isTargetBeta  = 1;
isTargetSigma = 1;
isTargetGamma = 1;
isTargetPis   = 1;
isTargetPsh   = 1;

% initial guess
alpha0 = 2;
beta0  = 2;
sigma0 = 2;
gamma0 = 2;
pis0   = 0.5;
psh0   = 0.5;

% Set up target params based on above input
% Priors
% hyperparameters for beta distributions below
if informPriors==1
    a1 = 1.5; 
    b1 = 2*a1;
    a2 = 1.5;
    b2 = a2;
    a3 = 1.5;
    b3 = 3*a3;
    a4 = 1.5;
    b4 = 4*a4;
else
    % for less informative priors
    a1 = 2;
    a2 = 2;
    a3 = 2;
    a4 = 2;
    b1 = 1/2;
    b2 = 1/2;
    b3 = 1/2;
    b4 = 1/2;
end

% define prior distributions for alpha, beta, sigma, gamma, pis, psh
if isTargetAlpha==1
    alphaPrior = @(alpha) gampdf(alpha,a1,1/b1);
else
    alpha0 = alpha;
    alphaPrior = @(alpha) 1;
end

if isTargetBeta==1
    betaPrior = @(beta) gampdf(beta,a2,1/b2);
else
    beta0 = beta;
    betaPrior = @(beta) 1;
end

if isTargetSigma==1
    sigmaPrior = @(sigma) gampdf(sigma,a3,1/b3);
else
    sigma0 = sigma;
    sigmaPrior = @(sigma) 1;
end

if isTargetGamma==1
    gammaPrior = @(gamma) gampdf(gamma,a4,1/b4);
else
    gamma0 = gamma;
    gammaPrior = @(gamma) 1;
end

if isTargetPis==1
    c1 = 1;
    d1 = 1;
    pisPrior = @(pis) betapdf(pis,c1,d1);
else
    pis0 = p_is;
    pisPrior = @(pis) 1;
end

if isTargetPsh==1
    c2 = 1;
    d2 = 1;
    pshPrior = @(psh) betapdf(psh,c2,d2);
else
    psh0 = p_sh;
    pshPrior = @(psh) 1;
end

% for 'priors only'
% alphaTrue = a1/b1;
% betaTrue  = a2/b2;
% sigmaTrue = a3/b3;
% gammaTrue = a4/b4;
% p_isTrue  = c1/(c1+d1);
% p_shTrue  = c2/(c2+d2);

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
    'isTarget',isTargetAlpha,'initGuess',alpha0,'prior',alphaPrior,...
    'proposalDist',alphaProposalDist,'logJacobian',alphaLogJacobian);

betaStruc = struct('name','beta','label','\beta','trueVal',beta,...
    'isTarget',isTargetBeta,'initGuess',beta0,'prior',betaPrior,...
    'proposalDist',betaProposalDist,'logJacobian',betaLogJacobian);

sigmaStruc = struct('name','sigma','label','\sigma','trueVal',sigma,...
    'isTarget',isTargetSigma,'initGuess',sigma0,'prior',sigmaPrior,...
    'proposalDist',sigmaProposalDist,'logJacobian',sigmaLogJacobian);

gammaStruc = struct('name','gamma','label','\gamma','trueVal',gamma,...
    'isTarget',isTargetGamma,'initGuess',gamma0,'prior',gammaPrior,...
    'proposalDist',gammaProposalDist,'logJacobian',gammaLogJacobian);

pisStruc = struct('name','pis','label','p_{is}','trueVal',p_is,...
    'isTarget',isTargetPis,'initGuess',pis0,'prior',pisPrior,...
    'proposalDist',pisProposalDist,'logJacobian',pisLogJacobian);

pshStruc = struct('name','psh','label','p_{sh}','trueVal',p_sh,...
    'isTarget',isTargetPsh,'initGuess',psh0,'prior',pshPrior,...
    'proposalDist',pshProposalDist,'logJacobian',pshLogJacobian);

targetParams =...
    [alphaStruc; betaStruc; sigmaStruc; gammaStruc; pisStruc; pshStruc];

% Run Metropolis-Hastings algorithm
numTargetParams = sum([targetParams.isTarget]);
saveName = ['Results_',num2str(numTargetParams),'params_',...
    num2str(numReps),'reps_',num2str(numIters),'iters'];

tic
[samples,proposals,acceptRates,acceptProbs,rejectedSamples] =...
    doMH(simParams,observationParams,observedData,targetParams,saveName);
runTime = toc;

% Save data to mat file
save([resultsFolder,'/',saveName,'.mat'],...
    'simParams','targetParams','numReps','numIters',...
    'T','SEEIIHRR','observedData',...
    'samples','proposals','acceptRates','acceptProbs',...
    'rejectedSamples','runTime')

% profile viewer
