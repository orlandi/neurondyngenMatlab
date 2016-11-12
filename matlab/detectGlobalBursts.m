function [meanTime, initialTime, finalTime, burstLength, IBI, totalSpikes, uniqueSpikes] = detectGlobalBursts(N, T, varargin)
% DETECTGLOBALBURSTS creates a new firings from a subset of electrodes
%       Standard paremeters:
%       --------------------
%       binSize: histogram binning
%       maxGap: 
%       threshold: in sigma deviations
%       minimumChannels: minimum number of active neurons/electrodes that
%       are required to identify a burst
%       debug (true/false)

params.binSize = 10e-3;
params.maxGap = 0.1;
params.threshold = 3;
params.minimumChannels = length(unique(N))/2;
params.debug = false;

params = parse_pv_pairs(params,varargin);

if(params.minimumChannels <= 1)
    params.minimumChannels = ceil(params.minimumChannels*length(unique(N)));
end

[y x] = hist(T,min(T):params.binSize:max(T));
if(params.debug)
    figure;plot(x,y,'.');
end
stdy = std(y);
meany = mean(y);
y((y-meany) < params.threshold*stdy) = 0;
if(params.debug)
    hold on;plot(x,y,'r.');
    line(xlim, [1 1]*(meany+params.threshold*stdy));
    line(xlim, [1 1]*(meany));
end
% Coordinates with bursts
ypos = find(y ~= 0);

i = 1;
k=1;
initialTime = [];
finalTime = [];
% Start by setting the burst limits
while(i <= length(ypos))
    j = i+1;
    while(j <= length(ypos))
        if((ypos(j) - ypos(i)) == (j-i))
            j = j+1;
        elseif((x(ypos(j))-x(ypos(j-1))) < params.maxGap)
            j = j+1;
        else
            initialTime(k) = x(ypos(i));
            finalTime(k) = x(ypos(j-1));
            k = k+1;
            i = j-1;
            j = 1;
            break;
        end
    end
    if((j >= length(ypos)) || (i == length(ypos)))
        initialTime(k) = x(ypos(i));
        finalTime(k) = x(ypos(end));
        break;
    end
    i=i+1;
end
burstLength = finalTime-initialTime;

meanTime = zeros(size(initialTime));
invalidBurst = zeros(size(initialTime));
totalSpikes = zeros(size(initialTime));
uniqueSpikes = zeros(size(initialTime));

mat = sortrows([T, N], 1);
T = mat(:, 1);
N = mat(:, 2);
% Now find the mean value of the burst (mean between all the spike times
% within a burst)
for i = 1:length(initialTime)
    fspike = find(T >= initialTime(i), 1, 'first');
    lspike = find(T > finalTime(i), 1, 'first')-1;
    if(isempty(lspike))
        lspike = length(T);
    else
        totalSpikes(i) = lspike-fspike+1;
    end
    % Now remove bursts that didn't recruit the minimum number of channels
    uniqueSpikes(i) = length(unique(N(fspike:lspike)));
    if((length(unique(N(fspike:lspike))) < params.minimumChannels) || (isempty(unique(N(fspike:lspike)))))
        invalidBurst(i) = 1;
    end
    % Maybe I should clean the signal in here, but for now...
    meanTime(i) = mean(T(fspike:lspike));
    if(isnan(meanTime(i)))
        meanTime(i) = T(fspike);
    end
end
meanTime = meanTime(~invalidBurst);
initialTime =  initialTime(~invalidBurst);
finalTime = finalTime(~invalidBurst);
burstLength = burstLength(~invalidBurst);
totalSpikes = totalSpikes(~invalidBurst);
uniqueSpikes = uniqueSpikes(~invalidBurst);

IBI = diff(meanTime);
