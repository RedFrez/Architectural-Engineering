import numpy as np
import pandas as pd
import math as m

N1 = {'node': 1, 'x': 0, 'y': 0, 'yD': 0, 'zD': 0 }
N2 = {'node': 2, 'x': 144, 'y': 0, 'yQ': 0, 'zQ': 0 }
N3 = {'node': 3, 'x': 264, 'y': 0, 'yD': 0, 'zQ': 0 }
N4 = {'node': 4, 'x': 300, 'y': 0, 'yQ': -10, 'zQ': 0 }
nodes = pd.DataFrame(data=[N1, N2, N3, N4],
    columns=['node', 'x', 'y', 'xQ', 'xD', 'yQ', 'yD', 'zQ', 'zD'])
nodes = nodes.set_index('node')

E1 = { 'element': 1, 'section': 1, 'node_i': 1, 'node_j': 2, 'hinge_j': 1 }
E2 = { 'element': 2, 'section': 1, 'node_i': 2, 'node_j': 3 }
E3 = { 'element': 3, 'section': 1, 'node_i': 3, 'node_j': 4 }
elements = pd.DataFrame(data=[E1, E2, E3],
    columns=['element', 'section', 'node_i', 'hinge_i', 'node_j', 'hinge_j'])


W1 = { 'section': 1, 'E': 1400, 'I': 864 }
sections = pd.DataFrame(
    data=[W1], 
    columns=['section', 'E', 'A', 'I'])

ep = elements.merge(sections, on='section').set_index('element')

Nnodes = len(nodes)
Nelems = len(elements)
Ndof = 8
Ndofpernode = Ndof / Nnodes
doffree = 1
dofspec = 1



def Generate_Lengths():
    D = np.zeros(Ndof)
    Q = np.zeros(Ndof)
    nFree = 0
    nSpec = 0
    # Determine type of analysis based on dof and add to T table
    # if nodes.xQ.notna() or nodes.xQ.notna(): # need to verify how this returns....
        # if (~all(isnan(Tnodes{:,'zQ'})) or ~all(isnan(Tnodes{:,'zD'})))
        #     Tp.type = 'frame';
        # elseif (all(isnan(Tnodes{:,'zQ'})) or (isnan(Tnodes{:,'zD'})))
        #     Tp.type = 'truss';
        # else
        #     error = 'check BC data'
        # end
    # elseif (~all(isnan(Tnodes{:,'yQ'})) or ~all(isnan(Tnodes{:,'yD'})))
    #     Tp.type = 'beam';
    # else
    #     error = 'check BC data'
    # end;

    # Calculate length for each element
    # if strcmp(Tp.type,'beam')
    #     Telprops.L = (Tnodes.x(Telprops.node_j)-Tnodes.x(Telprops.node_i));
    # elseif strcmp(Tp.type,'truss') or strcmp(Tp.type,'frame')
    # predefining as zeros not necessary but eliminates warnings

# ADD COLUMNS TO DF THEN BELOW SHOULD WORK......?!
    ep.Lx = (nodes.loc[ep.node_j, 'x']-nodes.loc[ep.node_i, 'x'])
    ep.Ly = (nodes.loc[ep.node_j, 'y']-nodes.loc[ep.node_i, 'y'])
    ep.L = m.sqrt( ep.Lx^2 + ep.Ly^2 )

    # define degrees of freedom for each type
    # if strcmp(Tp.type,'truss')
    dt = ["x","y"];
    Tp{:,'Nldof'} = 2;
    # elseif strcmp(Tp.type,'beam')
    #     dt = ["y","z"];
    #     Tp{:,'Nldof'} = 4;
    # elseif strcmp(Tp.type,'frame')
    #     dt = ["x","y","z"];
    #     Tp{:,'Nldof'} = 6;
    # else
    #     error = 'verify types'
    # end

    for inod = 1:Tp.Nnodes
        for idof = 1:Tp.Ndofpernode
            dof = Tp.Ndofpernode * inod - Tp.Ndofpernode + idof;
            Qdof = dt{idof}+"Q";
            Ddof = dt{idof}+"D";
            if ~(isnan(Tnodes{inod,Qdof}))
                nFree = nFree + 1;
                Q(dof) = Tnodes{inod,Qdof};
                doffree(nFree) = dof;
            elseif ~(isnan(Tnodes{inod,Ddof}))
                nSpec = nSpec +1;
                D(dof) = Tnodes{inod,Ddof};
                dofspec(nSpec) = dof;
            else
                error = 'bad BC data'
            end
        end
    end
return


def Generate_ElementStiffnessMatrix(Tp, props, Q, D, doffree, dofspec):
    # ***CORE OF ANALYSIS***
    K = np.zeros((Ndof,Ndof))
    ESM = pd.DataFrame(columns=['E', 'L', 'node_i', 'node_j', 'A', 'Lx', 'Ly'])
    for element in range(1,Nelems+1):
        # properties used by all types
        E = props{iel,'E'}
        L = props{iel,'L'}
        # not passed
        ni = props{iel,'node_i'}
        nj = props{iel,'node_j'}
        # determine k based on type of structural system
        # if strcmp(Tp.type,'truss')
        A = props{iel,'A'}
        Lx = props{iel,'Lx'}
        Ly = props{iel,'Ly'}
        [kel,T] = tkel(E,A,L,Lx,Ly)
        k = T'*kel*T
        eldofs = [2*ni-1 2*ni 2*nj-1 2*nj]
        # elseif strcmp(Tp.type,'beam')
        #     I = props{iel,'I'};
        #     hi = props{iel,'hinge_i'};
        #     hj = props{iel,'hinge_j'};
        #     [k] = bkel(E,I,L,hi,hj);
        #     eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
        # elseif strcmp(Tp.type,'frame')
        #     A = props{iel,'A'};
        #     I = props{iel,'I'};
        #     Lx = props{iel,'Lx'};
        #     Ly = props{iel,'Ly'};
        #     hi = props{iel,'hinge_i'};
        #     hj = props{iel,'hinge_j'};
        #     [kel,T] = fkel(E,A,I,L,Lx,Ly,hi,hj);
        #     k = T'*kel*T;
        #     eldofs  = [3*ni-2 3*ni-1 3*ni 3*nj-2 3*nj-1 3*nj];
        # else
        #     error = 'verify types'
        # end
        # Build K from k
        K(eldofs, eldofs) = K(eldofs, eldofs) + k;
    end
    # Q will not change below unless there is a D ~= 0
    Q(doffree) = Q(doffree) - K(doffree,dofspec)*D(dofspec);
    D(doffree) = inv(K(doffree,doffree))*Q(doffree);

    # ***POST-PROCESSING***
    Q = K*D;
    q = zeros(Tp.Nelems,Tp.Nldof); # local degrees of freedom based on type
    for iel in range(1, Tp.Nelems):
        # properties used by all types
        E = props{iel,'E'};
        L = props{iel,'L'};
        # not passed
        ni = props{iel,'node_i'}
        nj = props{iel,'node_j'}
        # determine k based on type of structural system
        # if strcmp(Tp.type,'truss')
            # A = props{iel,'A'};
            # Lx = props{iel,'Lx'};
            # Ly = props{iel,'Ly'};
            # [kel,T] = tkel(E,A,L,Lx,Ly);
            # eldofs = [2*ni-1 2*ni 2*nj-1 2*nj];
            # d = D(eldofs);
            # q(iel,:) = kel*T*d;
        # elseif strcmp(Tp.type,'beam')
        I = props{iel,'I'}
        hi = props{iel,'hinge_i'}
        hj = props{iel,'hinge_j'}
        [k] = bkel(E,I,L,hi,hj)
        eldofs = [2*ni-1 2*ni 2*nj-1 2*nj]
        d = D(eldofs)
        q(iel,:) = k*d
        # elseif strcmp(Tp.type,'frame')
        #     A = props{iel,'A'};
        #     I = props{iel,'I'};
        #     Lx = props{iel,'Lx'};
        #     Ly = props{iel,'Ly'};
        #     hi = props{iel,'hinge_i'};
        #     hj = props{iel,'hinge_j'};
        #     [kel,T] = fkel(E,A,I,L,Lx,Ly,hi,hj);
        #     eldofs  = [3*ni-2 3*ni-1 3*ni 3*nj-2 3*nj-1 3*nj];
        #     d = D(eldofs);
        #     q(iel,:) = kel*T*d;
    return

def beam_kel(E,I,L,hi,hj):
    # This makes the local beam 4x4 element stiffness matrix
    EIoL = E*I/L
    EIoL2 = E*I/L^2
    EIoL3 = E*I/L^3

    k = np.matrix(
        [12*EIoL3,  6*EIoL2, -12*EIoL3,  6*EIoL2],
        [6*EIoL2, 4*EIoL, -6*EIoL2, 2*EIoL],
        [-12*EIoL3, -6*EIoL2, 12*EIoL3, -6*EIoL2],
        [6*EIoL2, 2*EIoL, -6*EIoL2, 4*EIoL]
    )

    # if there is a hinge calc reduced stiffness mtx keR
    # keR has zeros for the rows & cols of the hinge dof (ihinge)
    # and the 3x3 reduced stiffness terms in the rows & cols
    # of the other dof (isolid)

    if m.isnan(hi) or m.isnan(hj):
        if m.isnan(hi): # hinge at end i
            isolid = np.matrix[1, 3, 4];
            ihinge = [2]
        else: # hinge at end j
            isolid = np.matrix[1, 2, 3]
            ihinge = [4]
        keR = np.zeros(4)
        keR(isolid,isolid) = ( k(isolid,isolid) - k(isolid,ihinge) 
            * k(ihinge,ihinge).getI() * k(ihinge,isolid))
        k = keR
    return k



# Read input spreadsheet and generate type and lengths
[Tp, Tnodes, Telements, Tsections, Telprops, D, Q, nFree, nSpec, doffree, dofspec] = ReadXls(name);

# Pass data to Script for processing
[Q, D, q] = ESMScript(Tp, Telprops, Q, D, doffree, dofspec);

