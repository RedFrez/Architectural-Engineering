function [Tp, Tnodes, Telements, Tsections, Telprops, D, Q, nFree, nSpec,...
        doffree, dofspec] = ReadXls(name)
    % Define initial variables
    Tp = readtable(name,'Sheet','auto');
    % Create table for nodes
    Tnodes = readtable(name,'Sheet','nodes','ReadRowNames',true);
    % Create table for elements
    Telements = readtable(name,'Sheet','elements','ReadRowNames',true);
    % Create table for sections
    Tsections = readtable(name,'Sheet','sections','ReadRowNames',true);
    % Connect the elements with their section properties
    Telprops = join(Telements,Tsections);
    % Create Matrix for calculations and to sort dofs
    D = zeros(Tp.Ndof,1); Q = zeros(Tp.Ndof,1); nFree = 0; nSpec = 0;

    % Determine type of analysis based on dof and add to T table
    if (~all(isnan(Tnodes{:,'xQ'})) || ~all(isnan(Tnodes{:,'xD'})))
        if (~all(isnan(Tnodes{:,'zQ'})) || ~all(isnan(Tnodes{:,'zD'})))
            Tp.type = 'frame';
        elseif (all(isnan(Tnodes{:,'zQ'})) || (isnan(Tnodes{:,'zD'})))
            Tp.type = 'truss';
        else
            error = 'check BC data'
        end
    elseif (~all(isnan(Tnodes{:,'yQ'})) || ~all(isnan(Tnodes{:,'yD'})))
        Tp.type = 'beam';
    else
        error = 'check BC data'
    end;

    % Calculate length for each element
    if strcmp(Tp.type,'beam')
        Telprops.L = (Tnodes.x(Telprops.node_j)-Tnodes.x(Telprops.node_i));
    elseif strcmp(Tp.type,'truss') || strcmp(Tp.type,'frame')
        % predefining as zeros not necessary but eliminates warnings
        Telprops{:,'Lx'} = 0;
        Telprops{:,'Ly'} = 0;
        Telprops{:,'L'} = 0;
        for iel = 1:Tp.Nelems
            ni = Telprops{iel,'node_i'};
            ix = Tnodes{ni,'x'};
            iy = Tnodes{ni,'y'};
            nj = Telprops{iel,'node_j'};
            jx = Tnodes{nj,'x'};
            jy = Tnodes{nj,'y'};
            lx = jx-ix;
            ly = jy-iy;
            Telprops{iel,'Lx'} = lx;
            Telprops{iel,'Ly'} = ly;
            Telprops{iel,'L'} = sqrt(lx^2+ly^2);
        end
    else
        error = "check things"
    end

    % define degrees of freedom for each type
    if strcmp(Tp.type,'truss')
        dt = ["x","y"];
        Tp{:,'Nldof'} = 2;
    elseif strcmp(Tp.type,'beam')
        dt = ["y","z"];
        Tp{:,'Nldof'} = 4;
    elseif strcmp(Tp.type,'frame')
        dt = ["x","y","z"];
        Tp{:,'Nldof'} = 6;
    else
        error = 'verify types'
    end

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
