function [k] = bkel(E,I,L,hi,hj)
    % This makes the local beam 4x4 element stiffness matrix
    
    EIoL = E*I/L; EIoL2 = E*I/L^2; EIoL3 = E*I/L^3;
    %
    k = [12*E*I/L^3  6*E*I/L^2 -12*E*I/L^3  6*E*I/L^2;...
            6*E*I/L^2  4*E*I/L    -6*E*I/L^2  2*E*I/L;...
          -12*E*I/L^3 -6*E*I/L^2  12*E*I/L^3 -6*E*I/L^2;...
            6*E*I/L^2  2*E*I/L    -6*E*I/L^2  4*E*I/L];
    % if there is a hinge calc reduced stiffness mtx keR
    % keR has zeros for the rows&cols of the hinge dof (ihinge)
    % and the 3x3 reduced stiffness terms in the rows&cols
    % of the other dof (isolid)

    if ~isnan(hi) || ~isnan(hj)
        if ~isnan(hi) % hinge at end i
            isolid = [1 3 4]; ihinge = [2];
        else % hinge at end j
            isolid = [1 2 3]; ihinge = [4];
        end
        keR = zeros(4);
        keR(isolid,isolid) = k(isolid,isolid) - ...
                k(isolid,ihinge)*inv(k(ihinge,ihinge))*k(ihinge,isolid);
        k = keR;
    end
return