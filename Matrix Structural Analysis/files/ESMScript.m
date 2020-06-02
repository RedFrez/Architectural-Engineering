function [Q, D, q]  = ESMScript(Tp, props, Q, D, doffree, dofspec)
    
    % ***CORE OF ANALYSIS***
    K = zeros(Tp.Ndof,Tp.Ndof);
    for iel = 1:Tp.Nelems
        % properties used by all types
        E = props{iel,'E'};
        L = props{iel,'L'};
        % not passed
        ni = props{iel,'node_i'};
        nj = props{iel,'node_j'};
        % determine k based on type of structural system
        if strcmp(Tp.type,'truss')
            A = props{iel,'A'};
            Lx = props{iel,'Lx'};
            Ly = props{iel,'Ly'};
            [kel,T] = tkel(E,A,L,Lx,Ly);
            k = T'*kel*T;
            eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
        elseif strcmp(Tp.type,'beam')
            I = props{iel,'I'};
            hi = props{iel,'hinge_i'};
            hj = props{iel,'hinge_j'};
            [k] = bkel(E,I,L,hi,hj);
            eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
        elseif strcmp(Tp.type,'frame')
            A = props{iel,'A'};
            I = props{iel,'I'};
            Lx = props{iel,'Lx'};
            Ly = props{iel,'Ly'};
            hi = props{iel,'hinge_i'};
            hj = props{iel,'hinge_j'};
            [kel,T] = fkel(E,A,I,L,Lx,Ly,hi,hj);
            k = T'*kel*T;
            eldofs  = [3*ni-2 3*ni-1 3*ni 3*nj-2 3*nj-1 3*nj];
        else
            error = 'verify types'
        end
        % Build K from k
        K(eldofs, eldofs) = K(eldofs, eldofs) + k;
    end
    % Q will not change below unless there is a D ~= 0
    Q(doffree) = Q(doffree) - K(doffree,dofspec)*D(dofspec);
    D(doffree) = inv(K(doffree,doffree))*Q(doffree);

    % ***POST-PROCESSING***
    Q = K*D;
    q = zeros(Tp.Nelems,Tp.Nldof); % local degrees of freedom based on type
    for iel = 1:Tp.Nelems
        % properties used by all types
        E = props{iel,'E'};
        L = props{iel,'L'};
        % not passed
        ni = props{iel,'node_i'};
        nj = props{iel,'node_j'};
        % determine k based on type of structural system
        if strcmp(Tp.type,'truss')
            A = props{iel,'A'};
            Lx = props{iel,'Lx'};
            Ly = props{iel,'Ly'};
            [kel,T] = tkel(E,A,L,Lx,Ly);
            eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
            d = D(eldofs);
            q(iel,:) = kel*T*d;
        elseif strcmp(Tp.type,'beam')
            I = props{iel,'I'};
            hi = props{iel,'hinge_i'};
            hj = props{iel,'hinge_j'};
            [k] = bkel(E,I,L,hi,hj);
            eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
            d = D(eldofs);
            q(iel,:) = k*d;
        elseif strcmp(Tp.type,'frame')
            A = props{iel,'A'};
            I = props{iel,'I'};
            Lx = props{iel,'Lx'};
            Ly = props{iel,'Ly'};
            hi = props{iel,'hinge_i'};
            hj = props{iel,'hinge_j'};
            [kel,T] = fkel(E,A,I,L,Lx,Ly,hi,hj);
            eldofs  = [3*ni-2 3*ni-1 3*ni 3*nj-2 3*nj-1 3*nj];
            d = D(eldofs);
            q(iel,:) = kel*T*d;
        else
            error = 'verify types'
        end
    end
return