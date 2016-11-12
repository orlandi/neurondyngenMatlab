function [C, T, T_max] = getClustering(network, varargin)

RS = network.RS;

k_i = RS'*ones(length(RS),1);
k_o = RS*ones(length(RS),1);
k_t = (RS+RS')*ones(length(RS),1);

T.loop = zeros(length(RS), 1);
T.attractor = zeros(length(RS), 1);
T.repeller = zeros(length(RS), 1);
T.conduit = zeros(length(RS), 1);
T.total  = zeros(length(RS), 1);

T_max.loop = zeros(length(RS), 1);
T_max.attractor = zeros(length(RS), 1);
T_max.repeller = zeros(length(RS), 1);
T_max.conduit = zeros(length(RS), 1);
T_max.total  = zeros(length(RS), 1);


T.loop = diag(RS^3);
T.attractor = diag((RS')*RS^2);
T.repeller = diag(RS^2*(RS'));
T.conduit = diag(RS*(RS')*RS);
T.total = 1/2*diag((RS+RS')^3);

T_max.loop = k_i.*k_o-diag(RS^2);
T_max.attractor = k_i.*(k_i-1);
T_max.repeller = k_o.*(k_o-1);
T_max.conduit = k_i.*k_o-diag(RS^2);
T_max.total = k_t.*(k_t-1)-2*diag(RS^2);

C.loop = T.loop./T_max.loop;
C.attractor = T.attractor./T_max.attractor;
C.repeller = T.repeller./T_max.repeller;
C.conduit = T.conduit./T_max.conduit;
C.total = T.total./T_max.total;

C.loop(isnan(C.loop)) = 0;
C.attractor(isnan(C.attractor)) = 0;
C.repeller(isnan(C.repeller)) = 0;
C.conduit(isnan(C.conduit)) = 0;
C.total(isnan(C.total)) = 0;
