function firings = loadFirings(seed, varargin)
% LOADFIRINGS loads the firings file used in the simulation
%       Standard paremeters:
%       --------------------
%       seed
%       pdir
%       subset (true/false)
%       file
%       subsetFile
%       rescaleTime (true/false) rescales from ms to s
%       rescaleIndex (true/false) adds 1 to the index
%
%       Full path of files is pdir/seed/*.txt

params.file = 'SpikeRecord.txt';
params.subsetFile = 'SpikeRecordSubset.txt';
params.pdir = '~/Projects/neuron11_data';
params.subset = true;
params.rescaleTime = true;
params.rescaleIndex = true;
params.emptyFirings = false;
params.noSeed = false;

params = parse_pv_pairs(params,varargin);
if(~params.noSeed)
    if(params.subset)
        spikefile = strcat(params.pdir, '/', num2str(seed), '/', params.subsetFile);
    else
        spikefile = strcat(params.pdir, '/', num2str(seed), '/', params.file);
    end
    spikefileFull = strcat(params.pdir, '/', num2str(seed), '/', params.file);
else
    spikefile = strcat(params.pdir, '/', params.file);
    spikefileFull = spikefile;
end


if(~params.emptyFirings)
    A=load(spikefile);

    % Rescaling times (from ms to s)
    if(params.rescaleTime)
        firings.T = A(:,2)/1000;
    else
        firings.T = A(:,2);
    end

    % Rescaling idx (from 1 to N)
    if(params.rescaleIndex)
        firings.N = A(:,1)+1;
    else
        firings.N = A(:,1);
    end
end

firings.file = spikefile;
firings.fileFull = spikefileFull;
firings.seed = seed;
firings.subset = params.subset;
firings.folder = strcat(params.pdir, '/', num2str(seed), '/');

