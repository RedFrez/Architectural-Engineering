function [kel,T] = fkel(E,A,I,L,Lx,Ly,hi,hj)
    % This makes the local frame 6x6 esm, and 6x6 transformation matrix 
    
    % preliminaries: dimensions, angles, and element properties
    EAoL = E*A/L; 
    EIoL = E*I/L; 
    EIoL2 = E*I/L^2; 
    EIoL3 = E*I/L^3; 
    % saving space below
    %
    % set up a blank for the 6x6 keL 
    kel = zeros(6); % 6 = Number dof
    % install the axial terms at local dof 1 and 4
    axial = [1 4]; % dof 1' 4'
    kel(axial,axial) = [EAoL -EAoL; -EAoL EAoL];
    %
    % build the 4x4 to put into the flexural terms at dof 2 3 5 6
    % this is complicated by the corrections for hinge at end i or j
    k0 =  [12*EIoL3,    6*EIoL2,   -12*EIoL3,   6*EIoL2;...
            6*EIoL2,    4*EIoL ,    -6*EIoL2,   2*EIoL;...
          -12*EIoL3,   -6*EIoL2,    12*EIoL3,  -6*EIoL2;...
            6*EIoL2,    2*EIoL ,    -6*EIoL2,   4*EIoL ];
    % check for hinge and make adjustments if necessary
    if ~isnan(hi) || ~isnan(hj)
        if ~isnan(hi) % hinge at end i
            isolid = [1 3 4]; ihinge = [2];
        else % hinge at end j
            isolid = [1 2 3]; ihinge = [4];
        end
        keR = zeros(4);
        keR(isolid,isolid) = k0(isolid,isolid) - ...
                k0(isolid,ihinge)*inv(k0(ihinge,ihinge))*k0(ihinge,isolid);
        k0 = keR;
    end

    % install the flexural terms into keL
    flex = [2 3 5 6]; % end of building element stiffness matrix
    kel(flex,flex) = k0;
    %
    % now build the transformation mtx
    cos = Lx/L; % getting cosine of angle
    sin = Ly/L; % getting sin of angle
    %
    % now build the transformation mtx
    T  = [  cos,    sin,    0,      0,      0,      0;...
           -sin,    cos,    0,      0,      0,      0;...
            0,      0,      1,      0,      0,      0;...
            0,      0,      0,      cos,    sin,    0;...
            0,      0,      0,     -sin,    cos,    0;...
            0,      0,      0,      0,      0,      1];  
return