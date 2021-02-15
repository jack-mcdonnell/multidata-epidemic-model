function newWeeklyCases = getWeeklyCases(numDays,tau,SEEIIHRR)
% This script gets the new weekly cases from the .mat files produced by 
% the epidemic simulations.
% This script is used by collectData.m and getLatentVars.m

% Store number of cases at start of each day
dailyStates = SEEIIHRR(1:1/tau:length(SEEIIHRR),:);

% Determine number of new symptomatic cases each day
newDailySympt = sum(dailyStates(2:end,[6,7,8,10]),2) -...
    sum(dailyStates(1:end-1,[6,7,8,10]),2);

% Determine number of new hospitalised cases each day
newDailyHosp = dailyStates(2:end,8) - dailyStates(1:end-1,8);

% Store new daily cases
newDailyCases = [newDailySympt newDailyHosp];

% Sum new daily cases over every 7 days to get new weekly cases
numWeeks = floor(numDays/7);
newWeeklyCases = zeros(numWeeks,2);
for w = 1:numWeeks
    newWeeklyCases(w,:) = sum(newDailyCases(7*(w-1)+1:7*w,:),1);
end

end