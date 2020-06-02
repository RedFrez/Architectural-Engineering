% Provide file name where data will be found
clear
clc

name = 'HW9-2.xlsx';

% Read input spreadsheet and generate type and lengths
[Tp, Tnodes, Telements, Tsections, Telprops, D, Q, nFree, nSpec,...
    doffree, dofspec] = ReadXls(name);

% Pass data to Script for processing
[Q, D, q] = ESMScript(Tp, Telprops, Q, D, doffree, dofspec);


% Printing of Results based of type of structure
if strcmp(Tp.type,'truss')
    % Formatted Truss Print
    fprintf('\nDOF\t Forces and Displacements \n')
    for iel = 1:Tp.Ndof
        fprintf('DOF %.f\tQ=%10.3f  D=%10.3f\n', [iel, Q(iel),D(iel)])
    end
    fprintf('\nElement\t Shear and Moments \n')
    for iel = 1:Tp.Nelems
        fprintf('Axi=%10.3f  Element %.f   Axj=%10.3f \n',...
            [q(iel,1), iel, q(iel,2)])
    end
elseif strcmp(Tp.type,'beam')
    % Formatted Beam Print
    fprintf('\nDOF\t Forces and Displacements \n')
    for inn = 1:Tp.Nnodes
        i1 = 2*inn-1;
        i2 = 2*inn;
        fprintf('Node %.f | DOF %.f\tQ=%9.3f  D=%9.3f | DOF %.f\tQ=%9.3f  D=%9.3f\n',...
            [inn, i1, Q(i1),D(i1), i2, Q(i2),D(i2)])
    end
    fprintf('\nElement\t Shear and Moments \n')
    for iel = 1:Tp.Nelems
        fprintf('Vyi=%10.3f  Mzi=%10.3f   Element %.f   Vyj=%10.3f  Mzj=%10.3f\n',...
            [q(iel,1:2), iel, q(iel,3:4)])
    end
elseif strcmp(Tp.type,'frame')
    % Formatted Frame Print
    fprintf('Node\t DOF\t Forces and Displacements \n')
    for inn = 1:Tp.Nnodes
        i1 = 3*inn-2;
        i2 = 3*inn-1;
        i3 = 3*inn;
        fprintf('Node %.f | DOF %2.f Q=%9.3f  D=%9.3f | DOF %2.f Q=%9.3f  D=%9.3f | DOF %2.f Q=%9.3f  D=%9.3f\n',...
            [inn, i1 Q(i1),D(i1), i2 Q(i2),D(i2), i3 Q(i3),D(i3)])
    end
    fprintf('\nElement\t Shear and Moments \n')
    for iel = 1:Tp.Nelems
        fprintf('Axi=%10.3f  Vyi=%10.3f  Mzi=%10.3f   Element %.f   Axj=%10.3f  Vyj=%10.3f  Mzj=%10.3f\n',...
        [q(iel,1:3), iel, q(iel,4:6)])
    end
else
    error = 'verify types';
end