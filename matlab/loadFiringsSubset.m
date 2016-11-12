function [N, T] = loadFiringsSubset(firings, Ti, Tf, varargin)
params.mode = 'full';
params.Nlines = 3e6;

params = parse_pv_pairs(params,varargin); 

Nlines = params.Nlines;
% Load the appropiate firings
if(strcmp(params.mode,'full'))
    if(firings.subset)
        fid = fopen(firings.fileFull);
        A = textscan(fid, '%f %f %[^\n]', Nlines);
        tfirings = [A{2}/1000, A{1}+1];
        while(Ti > tfirings(end, 1))
            A = textscan(fid, '%f %f %[^\n]', Nlines);
            tfirings = [A{2}/1000, A{1}+1];
        end
        fs = find(tfirings(:,1) >= Ti, 1, 'first');
        tfirings = tfirings(fs:end,:);
        % Keep expanding the file till all the burst fits inside firings
        while(Tf > tfirings(end, 1))
            A = textscan(fid, '%f %f %[^\n]', Nlines);
            tfirings = [tfirings; A{2}/1000, A{1}+1];
        end
        fclose(fid);
        [N, T] = getSpikedNeuronsFromTimeInterval(tfirings(:,2), tfirings(:,1), Ti, Tf);
    else
        [N, T] = getSpikedNeuronsFromTimeInterval(firings.N, firings.T, Ti, Tf);
    end
elseif(strcmp(params.mode,'simplified'))
    N = firings.N;
    T = firings.T;
end
