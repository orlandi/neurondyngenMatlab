function [network] = loadNetwork(dir, varargin)
%LOADNETWORK loads the network structure used in the simulation
%       Standard paremeters:
%       --------------------
%       connectivityFile
%       mapFile
%       sizeFile
%       sturctureFile
%       pdir
%       periodic (true/false)
%       rescaleIndex (true/false) adds 1 to the index
%       skipConsistencyCheck (true/false)
%
%       Full path of files is pdir/dir/*.txt

params.connectivityFile = 'cons.txt';
params.mapFile = 'map.txt';
params.sizeFile = 'sizes.txt';
params.structureFile = 'NetworkStructure.txt';
params.pdir = '~/Projects/neuron11_data/networks';
params.rescaleIndex = true;
params.skipConsistencyCheck = false;
params.periodic = false;
params.networkSizeResolution = 0.1;

params = parse_pv_pairs(params,varargin);

seed = strcat(params.pdir,'/', dir,'/', params.connectivityFile);
mapseed = strcat(params.pdir,'/', dir,'/', params.mapFile);
if(~isempty(params.sizeFile))
    sizeseed = strcat(params.pdir,'/', dir,'/', params.sizeFile);
end

conns = load(seed);
% Create the connectivity matrix
if(params.rescaleIndex)
    network.RS = sparse(conns(:,1)+1, conns(:,2)+1, 1, max(max(conns))+1, max(max(conns))+1);
else
    network.RS = sparse(conns(:,1), conns(:,2), 1, max(max(conns)), max(max(conns)));
end
clear conns;
neuronalMap = load(mapseed);
network.X = neuronalMap(:,2);
network.Y = neuronalMap(:,3);
network.totalSizeX = round((max(network.X)-min(network.X))/params.networkSizeResolution)*params.networkSizeResolution;
network.totalSizeY = round((max(network.Y)-min(network.Y))/params.networkSizeResolution)*params.networkSizeResolution;

network.inpCon = sum(network.RS,1)';
network.outCon = sum(network.RS,2);

network.dir = dir;
network.pdir = params.pdir;
network.fulldir = strcat(params.pdir,'/', dir, '/');
network.connectivityFile = params.connectivityFile;

network.periodic = params.periodic;

if(~isempty(params.sizeFile))
    sizes = load(sizeseed);
    network.dTreeRadius = sizes(:,3);
    network.axonLength = sizes(:,4);
    network.axonEndToEnd = sizes(:,5);

    % Check consistency between files
    if(~params.skipConsistencyCheck)
        if((any(sizes(:,6) ~= network.inpCon)) || (any(sizes(:,7) ~= network.outCon)))
            error('Mismatch between connectivity and sizes file');
        end
    end
end
