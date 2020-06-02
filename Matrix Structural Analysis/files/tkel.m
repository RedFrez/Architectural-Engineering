function [kel, T] = tkel(E, A, L, Lx, Ly)
    % This makes the local truss 2x2 esm and 2x4 transformation matrix 

    kel = [E*A/L, -E*A/L; -E*A/L, E*A/L];

    cos = Lx/L; % getting cosine of angle
    sin = Ly/L; % getting sin of angle
    % build the transformation mtx
    T = [cos, sin, 0, 0; 0, 0, cos, sin];
return