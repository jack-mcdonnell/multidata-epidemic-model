function data = collectData(modelParams,observationParams,SEEIIHRR)

numDays  = modelParams.numDays;
tau      = modelParams.tau;
pFT      = observationParams.pFT;
pFC      = observationParams.pFC;
p_GPtest = observationParams.p_GPtest;
p_Htest  = observationParams.p_Htest;
p_pos    = observationParams.p_pos;
ILI_Gnf  = observationParams.ILI_Gnf;
ILI_Hnf  = observationParams.ILI_Hnf;

newCasesWeekly = getWeeklyCases(numDays,tau,SEEIIHRR);

% Latent data
I_p = newCasesWeekly(:,1);
H_p = newCasesWeekly(:,2);

% Generate observed data using the latent data I_p, H_p
% FluTracking
Rs_Gf  = binornd(I_p, pFT);         % with flu report symptoms
Rs_Gnf = binornd(ILI_Gnf, pFT);    	% nonflu ILI report symptoms
Rc_Gf  = binornd(Rs_Gf, p_GPtest); 	% with flu report tested
Rc_Gnf = binornd(Rs_Gnf, p_GPtest);	% nonflu ILI report tested

Rs_Hf  = binornd(H_p, pFT);         % with flu report hospitalised
Rs_Hnf = binornd(ILI_Hnf, pFT);    	% nonflu ILI report hospitalised
Rc_Hf  = binornd(Rs_Hf, p_Htest);   % with flu (H) report tested
Rc_Hnf = binornd(Rs_Hnf, p_Htest);  % nonflu ILI (H) report tested

% Observed FluTracking data
Rs_G   = Rs_Gf + Rs_Gnf;            % report symptoms (GP)
Rc_G   = Rc_Gf + Rc_Gnf;            % report tested (GP)
Rpos_G = binornd(Rc_Gf, p_pos);     % report positive test (GP)

Rs_H   = Rs_Hf+Rs_Hnf;            	% report symptoms (Hosp)
Rc_H   = Rc_Hf+Rc_Hnf;             	% report tested (Hosp)
Rpos_H = binornd(Rc_Hf,p_pos);     	% report positive test (Hosp)

% FluCAN
H_FClessFT = binornd(H_p-Rpos_H,pFC*p_Htest*p_pos); % in FC but not FT
H_FCandFT  = binornd(Rpos_H,pFC);       	% pos hosp cases in FC and FT
H_FC       = H_FClessFT + H_FCandFT;        % total FC

% Case notifications
C_uniqueGP = binornd(I_p-Rpos_G, p_GPtest*p_pos);
C_uniqueH  = binornd(H_p-Rpos_H-H_FClessFT, p_Htest*p_pos);
C          = C_uniqueGP + C_uniqueH + Rpos_G + Rpos_H + H_FClessFT;

% Store observed data in data structure
data        = struct;
data.I_true = I_p;
data.H_true = H_p;

data.Rs_G   = Rs_G;
data.Rc_G   = Rc_G;
data.Rpos_G = Rpos_G;
data.Rs_H   = Rs_H;
data.Rc_H   = Rc_H;
data.Rpos_H = Rpos_H;
data.H_FC   = H_FC;
data.C      = C;

data.H_FCandFT  = H_FCandFT;
data.C_uniqueGP = C_uniqueGP;

end

