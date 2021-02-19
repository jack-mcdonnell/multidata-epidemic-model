function logP = ...
    computeLogPdatagivenlatent(observationParams,observedData,I_p,H_p)
% This function computes logP(FT,FC,C|I^p,H^p) for a given simulation.

pFT      = observationParams.pFT;
p_GPtest = observationParams.p_GPtest;
p_Htest  = observationParams.p_Htest;
p_pos    = observationParams.p_pos;
pFC      = observationParams.pFC;
% ILI_Gnf  = observationParams.ILI_Gnf;
% ILI_Hnf  = observationParams.ILI_Hnf;

Rs_G   = observedData.Rs_G;
Rc_G   = observedData.Rc_G;
Rpos_G = observedData.Rpos_G;
Rs_H   = observedData.Rs_H;
Rc_H   = observedData.Rc_H;
Rpos_H = observedData.Rpos_H;
H_FC   = observedData.H_FC;
C      = observedData.C;

% Assume for now we know these (lifting the skirts of FC anf C)
C_uniqueGP = observedData.C_uniqueGP;
H_FCandFT  = observedData.H_FCandFT;

T      = length(I_p); 	% num weeks
logP_t = zeros(T,1); 	% initialise log-likelihood

for t = 1:T
    % unobserved data
    It_p = I_p(t);
    Ht_p = H_p(t);
%     ILIt_Gnf = ILI_Gnf;
%     ILIt_Hnf = ILI_Hnf;
    
    % Observed data
    % FluTracking
    Rst_G   = Rs_G(t);      % report symptoms (not hospitalised)
    Rct_G   = Rc_G(t);      % report test at GP
    Rpost_G = Rpos_G(t);    % report positive GP test
    Rst_H   = Rs_H(t);      % report symptoms (hospitalised)
    Rct_H   = Rc_H(t);      % report hospital test
    Rpost_H = Rpos_H(t);    % report positive hosp test
    Ht_FC   = H_FC(t);     	% FluCAN
    Ct      = C(t);        	% Case notifications
    
    Ht_FCandFT  = H_FCandFT(t);
    Ct_uniqueGP = C_uniqueGP(t);
    
    % FT GP (assume no other ILI)
    lnProbRposG = lnBinoPdf(Rpost_G, Rct_G, p_pos);
    lnProbRcG   = lnBinoPdf(Rct_G, Rst_G, p_GPtest);
    lnProbRsG   = lnBinoPdf(Rst_G, It_p, pFT);
    lnProbFTGP  = lnProbRposG + lnProbRcG + lnProbRsG;
    % FT Hosp
    lnProbRposH = lnBinoPdf(Rpost_H, Rct_H, p_pos);
    lnProbRcH   = lnBinoPdf(Rct_H, Rst_H, p_Htest);
    lnProbRsH   = lnBinoPdf(Rst_H, Ht_p, pFT);
    lnProbFTH   = lnProbRposH + lnProbRcH + lnProbRsH;
    
    % FT total
    lnProbFT    = lnProbFTGP + lnProbFTH;

    % FluCAN (assume know H^FCandFT)
    lnProbFC = lnBinoPdf(Ht_FC-Ht_FCandFT,Ht_p-Rpost_H,pFC*p_Htest*p_pos);
    
    % Case note's (assume know C^uniqueGP)
%     lnProbC = lnBinoPdf(Ct_uniqueGP,It_p-Rpost_G,p_GPtest*p_pos);
    % Ct_uniqueH = Ct-Ct_uniqueGP-Rpost_G-Rpost_H-Ht_FC+Ht_FCandFT;
	% lnBinoPdf(Ct_uniqueH,Ht_p-Rpost_H-Ht_FC+Ht_FCandFT,p_Htest*p_pos)
    
%     lnProbFT = 0;
%     lnProbFC = 0;
    lnProbC  = 0;
    
    % Combine all logProbs
    logP_t(t) = lnProbFT + lnProbFC + lnProbC;
end

% sum all logProbs over time
logP = sum(logP_t);

end


function lnPDF = lnBinoPdf(x,n,p)
% This function computes the log of the binomial PDF

if n<x
    lnPDF = log(0);
else
    lnPDF = lnNchooseK(n,x) + x*log(p) + (n-x)*log(1-p);
end

end


function R = lnNchooseK(n,k)
% This function computes the log of the binomial coefficient,
% faster than lnfac(x)-lnfac(y) - lnfac(x-y)

N = n-k+1:n;
K = 1:k;

R = sum(log(N)) - sum(log(K));

end
