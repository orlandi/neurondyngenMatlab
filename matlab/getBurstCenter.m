function center = getBurstCenter(network, firings, Ti, Tf, varargin)
% GETBURSTCENTER Obtains the center of the burst between Ti and Tf
params.Nspikes = 100;
params.cleanTime = 20e-3;
params.getStd = false;
params.mode = 'full';

params = parse_pv_pairs(params,varargin); 

Nspikes = params.Nspikes;

% Get the spikes
if(strcmp(params.mode, 'full'))
    burstFirings = getFullBurstSpikes(firings, Ti, Tf);
else
    burstFirings = firings;
end

% Clean the spike train

[newN, newT] = cleanSpikeTrain(burstFirings.N, burstFirings.T, params.cleanTime);
if(length(newN) > Nspikes)
    valid = 1:Nspikes;
else
    valid = 1:length(newN);
end
% First estimate of the nucleation center
meanX = mean(network.X(newN(valid)));
meanY = mean(network.Y(newN(valid)));
% Get the standard deviation. Warning, not ready for periodic BC)
if(params.getStd)
    stdX = std(network.X(newN(valid)));
    stdY = std(network.Y(newN(valid)));
end
    
% If the system is periodic, check again relative to this new position
if(network.periodic)
    [X, Y, realIdx] = periodicSet(network.X, network.Y, network.totalSizeX, network.totalSizeY, network.totalSizeX/2, network.totalSizeY/2);
    %[X, Y, realIdx] = periodicSet(network.X, network.Y, network.totalSizeX, network.totalSizeY, network.totalSizeX, network.totalSizeY);
    periodicIdx = zeros(length(valid), 1);
    for i = 1:length(valid)
        repeats = find(realIdx == newN(valid(i)));
        dist = (X(repeats)-meanX).^2 + (Y(repeats)-meanY).^2;
        [~, idx] = min(dist);
        periodicIdx(i) = repeats(idx);
    end
    meanX = mean(X(periodicIdx(valid)));
    meanY = mean(Y(periodicIdx(valid)));
end
if(params.getStd)
    center = [meanX, meanY, stdX, stdY];
else
    center = [meanX, meanY];
end

