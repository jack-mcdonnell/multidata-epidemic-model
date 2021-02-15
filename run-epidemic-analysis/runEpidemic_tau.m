function [T,SEEIIHRR]=...
    runEpidemic_tau(simParams,alpha,beta,sigma,gamma,p_is,p_sh)
% Simulates SEEIIRH stochastic household epidemic using tau-leap method

% Set params
hh      = simParams.hh;
maxTime = simParams.numDays;
tau     = simParams.tau;

% Set params
numStates = 10;             % S,E1,E2,I1a,I2a,I1s,I2s,H,Ra,Rs
numEvents = 9;              % S->E1, E1->E2 etc.

numHH = length(hh);       	% number of households
PopN  = sum(hh);           	% total pop
k     = hh';             	% get rid of k ?
I0    = distributeInitialInfected(simParams.infecInit,numHH);

% tau = 1/10;              	% single time step
T = 0:tau:maxTime;          % time vector

% p_sh = p_ih/p_is;
lam1 = 2*sigma;
lam2 = 2*gamma;

% Transition rates
r      = zeros(numHH,numEvents);
change = zeros(numEvents, numStates);
            % S E1 E2 I1a I2a I1s I2s H Ra Rs
change(1,:) = [-1 +1 0 0 0 0 0 0 0 0];    % S   -> E1
change(2,:) = [0 -1 +1 0 0 0 0 0 0 0];    % E1  -> E2
change(3,:) = [0 0 -1 +1 0 0 0 0 0 0];    % E2  -> I1a
change(4,:) = [0 0 0 -1 +1 0 0 0 0 0];    % I1a -> I2a
change(5,:) = [0 0 -1 0 0 +1 0 0 0 0];    % E2  -> I1s
change(6,:) = [0 0 0 0 0 -1 +1 0 0 0];    % I1s -> I2s
change(7,:) = [0 0 0 0 0 -1 0 +1 0 0];    % I1s -> H
change(8,:) = [0 0 0 0 -1 0 0 0 +1 0];    % I2a -> Ra
change(9,:) = [0 0 0 0 0 0 -1 0 0 +1];    % I2s -> Rs

% Initialisation
S   = hh';
E1  = zeros(length(hh),1);
E2  = zeros(length(hh),1);
I1a = zeros(length(hh),1);
I2a = zeros(length(hh),1);
I1s = zeros(length(hh),1);
I2s = zeros(length(hh),1);
H   = zeros(length(hh),1);
Ra  = zeros(length(hh),1);
Rs  = zeros(length(hh),1);

Initialstate = [S E1 E2 I1a I2a I1s I2s H Ra Rs];
% seed infection
Initialstate(1:length(I0),:) = Initialstate(1:length(I0),:)+I0*change(1,:);
Currstate = Initialstate;

if simParams.recordDaily
    lengthTime = maxTime+1;         % if record daily
else
    lengthTime = maxTime/tau+1;   	% if record at each time step
end
SEEIIHRR = zeros(numHH,numStates,lengthTime);   % SEIR time series
SEEIIHRR(:,:,1) = Currstate;

% Loop through time until reach maxTime
count = 1;
% while sum(Currstate(:,1))-sum(sum(Currstate(:,7:9))) > 0 && T(count) < maxTime
while T(count) < maxTime
    S   = Currstate(:,1);
    E1  = Currstate(:,2);
    E2  = Currstate(:,3);
    I1a = Currstate(:,4);
    I2a = Currstate(:,5);    
    I1s = Currstate(:,6);
    I2s = Currstate(:,7);
%     H  = Currstate(:,8);
%     Ra = Currstate(:,9);
%     Rs = Currstate(:,10);
    Iall = I1a+I2a+I1s+I2s;
    totalI = sum(Iall);
    
    % Calculate transition rates 
    not1  = (hh'~=1);      	% indices of households with > 1 person
    Snot1 = S(not1);      	% households with >1 person in S
    Inot1 = Iall(not1);    	% households with >1 person in I
    
    r(:,1) = alpha*S.*totalI./(PopN-1);	% S to E1, b/w hh
    r(not1,1) = r(not1,1)+(beta*Snot1.*Inot1)./(k(k~=1)-1);	% w/in hh
    r(:,2) = lam1*E1;               % E1 to E2
    r(:,3) = lam1*E2*(1-p_is);    	% E2 to Ia1
    r(:,4) = lam2*I1a;           	% Ia1 to Ia2
    r(:,5) = lam1*E2*p_is;       	% E2 to Is1
    r(:,6) = lam2*(1-p_sh)*I1s;    	% Is1 to Is2
    r(:,7) = lam2*p_sh*I1s;       	% Is1 to H
    r(:,8) = lam2*I2a;             	% Ia2 to Ra
    r(:,9) = lam2*I2s;             	% Is2 to Rs
    
    % Transitions
    for i = 1:numEvents        
%         num = poissrnd(r(:,i).*tau);
        num = myPoissrnd(r(:,i).*tau);
                
        % Make sure things don't go negative
        use = min([num Currstate(:,change(i,:)<0)],[],2);
        Currstate = Currstate + change(i,:).*use;   % Update current state
    end
    count = count+1;
    
    % record result, either start of each day or at each time step
    if simParams.recordDaily
        if floor(T(count)) ~= floor(T(count-1))     % if new day
            SEEIIHRR(:,:,floor(T(count))+1) = Currstate;
        end
    else
        SEEIIHRR(:,:,count) = Currstate;
    end
    
end

% if want record daily, return shorter time vector
if simParams.recordDaily
    T = T(1:1/tau:end);
end

SEEIIHRR = permute(SEEIIHRR, [3 2 1]);      % swap hh and time dimensions
SEEIIHRR = sum(SEEIIHRR,3);                 % sum over households

end


function I0=distributeInitialInfected(infecInit,numHH)
% This function takes an integer number of infected individuals and the
% number of households in the population and returns the initial infected
% vector: I0=infecInit if numHH=1, else a vector of ones the length of the
% number of households.

infectedHH = min(infecInit,numHH);
infectedPerHH = infecInit/infectedHH;
I0 = infectedPerHH*ones(infectedHH,1);

end


function x = myPoissrnd(lam)
% This function sometimes quicker than MATLAB's poissrand().
% Input lam can be single float or array of floats.
    
    x = 0*lam;
    p = exp(-lam);
    s = p;

    u = rand([1, length(lam)]);
    
    for i=1:length(lam)
        while u(i) > s(i)
            x(i) = x(i)+1;
            p(i) = p(i).*lam(i)./x(i);
            s(i) = s(i)+p(i);
        end
    end
end

