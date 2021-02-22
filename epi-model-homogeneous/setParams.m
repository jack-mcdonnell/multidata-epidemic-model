function [simParams,transmissionParams,observationParams,priorParams] = setParams()
% Set all the parameters for the simulation

% Simultion parameters
population  = 1e5;          % Set homogeneous popn
numDays	    = 98;           % max number of days in sim
tau	        = 0.1;          % time step for tau-leap algorithm
numReps     = 100;          % number of reps for pseudomarginal estimate
numIters    = 1000;         % number of iterations for Metropolis-Hastings
saveFreq    = 100;          % save results every saveFreq iterations
recordDaily = 0;            % boolean, to record infection data daily

initialInfected  = 3;       % Number of ppl initially infected

plotEpidemic     = 0;       % boolean, to plot epidemic trajectories
plotObservedData = 0;       % boolean, to plot observed data

% Saving results
resultsFolder = 'Results';  % Results directory

% Transmission params ("unknown")
alpha = 0;  %.3;       	% transmission rate b/w households
beta  = .5;             % transmission rate w/in/w households
sigma = 1/3;            % 1/sigma = incubation period
gamma = 1/7;            % 1/gamma = infectious period
p_is  = 0.8;            % prob symptoms given infected
p_ih  = 0.01;           % prob hospitalised given infected
p_sh  = p_ih/p_is;      % prob hospitalised given symptoms


% Observation params
pFT      = 0.01;        % prop popn enrolled in fluTracking
pFC      = 0.4;         % prop hospitals in FluCAN
p_GPtest = 0.5;         % prob sympt person tested by GP
p_Htest  = 0.8;         % prob sympt person tested in hospital
p_pos    = 0.9;         % prob test produces true positive
ILI_Gnf  = 0;           % prop nonflu ILI present to GP
ILI_Hnf  = 0;           % prop nonflu ILI present to Hospital


% Prior params
inferAlpha = 0;         % boolean, to include param in inference
alpha0     = 2;         % initial value for MH sampler
a1         = 1.5;       % beta dist hyperparams
b1         = 2*a1;
	
inferBeta  = 1;
beta0      = 2;
a2         = 1.5;
b2         = a2;

inferSigma = 1;
sigma0     = 2;
a3         = 1.5;
b3         = 3*a3;

inferGamma = 1;
gamma0     = 2;
a4         = 1.5;
b4         = 4*a4;

inferPis   = 1;         % p_is = Pr(symptoms | infected)
pis0       = 0.5;

inferPsh   = 1;         % p_is = Pr(hospitalised | symptoms)
psh0       = 0.5;

% for 'priors only'
% alphaTrue = a1/b1;
% betaTrue  = a2/b2;
% sigmaTrue = a3/b3;
% gammaTrue = a4/b4;
% p_isTrue  = c1/(c1+d1);
% p_shTrue  = c2/(c2+d2);


% Save params in structs
simParams      	      = struct;
simParams.hh          = population;
simParams.numDays     = numDays;
simParams.days        = days;
simParams.tau         = tau;
simParams.numReps     = numReps;
simParams.numIters    = numIters;
simParams.saveFreq    = saveFreq;
simParams.recordDaily = recordDaily;
simParams.infecInit   = initialInfected;
simParams.plotEpidemic     = plotEpidemic;
simParams.plotObservedData = plotObservedData;
simParams.resultsFolder    = resultsFolder;

% Transmission params
transmissionParams       = struct;
transmissionParams.alpha = alpha;
transmissionParams.beta  = beta;
transmissionParams.sigma = sigma;
transmissionParams.gamma = gamma;
transmissionParams.p_is  = p_is;
transmissionParams.p_ih  = p_ih;
transmissionParams.p_sh  = p_sh;

% Observation params ("known")
observationParams          = struct;
observationParams.pFT      = pFT;
observationParams.pFC      = pFC;
observationParams.p_GPtest = p_GPtest;
observationParams.p_Htest  = p_Htest;
observationParams.p_pos    = p_pos;
observationParams.ILI_Gnf  = ILI_Gnf;
observationParams.ILI_Hnf  = ILI_Hnf;

% Prior params
priorParams            = struct;
priorParams.inferAlpha = inferAlpha;
priorParams.inferBeta  = inferBeta;
priorParams.inferSigma = inferSigma;
priorParams.inferGamma = inferGamma;
priorParams.inferPis   = inferPis;
priorParams.inferPsh   = inferPsh;
priorParams.alpha0     = alpha0;
priorParams.beta0      = beta0;
priorParams.sigma0     = sigma0;
priorParams.gamma0     = gamma0;
priorParams.pis0       = pis0;
priorParams.psh0       = psh0;
priorParams.a1         = a1;
priorParams.b1         = b1;
priorParams.a2         = a2;
priorParams.b2         = b2;
priorParams.a3         = a3;
priorParams.b3         = b3;
priorParams.a4         = a4;
priorParams.b4         = b4;

end

