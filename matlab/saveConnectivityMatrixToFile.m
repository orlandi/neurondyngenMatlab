function saveConnectivityMatrixToFile(RS, file, varargin)
% Decompose the matrix to create a new connectivity file for C code
params.weighted = false;
params = parse_pv_pairs(params,varargin); 


[i,j,~] = find(RS);
val = find(RS);
if(params.weighted)
    newConFile = [i-1, j-1, RS(val)];
else
    newConFile = [i-1, j-1];
end
newConFile = sortrows(newConFile,1);

fid = fopen(file, 'w');
for i=1:length(newConFile);
    if(params.weighted)
        fprintf(fid, '%d %d %.5f\n', newConFile(i, :));
    else
        fprintf(fid, '%d %d\n', newConFile(i, :));
    end
end
fclose(fid);
