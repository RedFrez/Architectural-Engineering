clear
clc
%
% structure input
k = [10.77 -.4;-.4 .4];   % kip/in
m = [.00777 0; 0 .000518]; % kip s^2/in
zeta = .02;
%
% loading input
p0 = [.2; 0]; % kip
OmegaBar = 36;
%
% input number of modes to be analyzed
modes = 2;
%
% prepare time control (make vector with time)
del_t = 0.01;
t_max = 2;
t = 0:del_t:t_max;
%
% mode shapes and freqs
[PHI,OMEGA2] = eig(k,m);
K = PHI'*k*PHI;
Omega = sqrt(OMEGA2);
P = PHI' * p0;
dof = size(p0,1);
%
% loop through modes
for n = 1:modes
    n_Omega = Omega(n,n);
    n_OmegaD = n_Omega*sqrt(1-zeta^2);
    n_p = P(n);
    n_k = K(n,n);
    beta = OmegaBar/n_Omega;
    Rd = ((1-beta^2)^2 + (2*zeta*beta)^2)^-0.5;
    phi = atan((2* zeta * beta)/(1-(beta^2)));
    if phi < 0
        phi = phi + pi;
    end
    A = (n_p/n_k)*(Rd^2)*((2* zeta * beta));
    B = (n_p/n_k)*(Rd^2)*(OmegaBar/n_OmegaD)*...
        ((2*(zeta^2))+(beta^2)-1);
    % loop thru time steps for the mode
    for i = 1:size(t,2)
        mode(n).p(i) = n_p*sin(OmegaBar*t(i));
        mode(n).q(i) = exp(-zeta*n_Omega*t(i))*...
            (A*cos(n_OmegaD*t(i))+B*sin(n_OmegaD*t(i)))...
            +(n_p/n_k)*Rd*sin(OmegaBar*t(i)-phi);
    end
    % calculate the absolute max for q to use later
    mode(n).qmax = max(abs(mode(n).q));
end
%
% loop through modes to convert back to u for each
% need to use all the q values so must be done as a separate loop
for d = 1:dof
    u_temp = 0;
    for f = 1:dof
        u_temp = u_temp + PHI(d,f)*mode(f).q;
    end
    mode(d).u = u_temp;
    mode(d).umax = max(abs(mode(d).u));
end
%
qmax = max(vertcat(mode.qmax));
qmax_lim = (qmax*1.15);
umax = max(vertcat(mode.umax));
umax_lim = (umax*1.15);
%
% bonus data for labeling of max on plots
for n = 1:modes
    % data for qmax
    ant(n).qml = find(abs(mode(n).q) == mode(n).qmax); % location
    ant(n).qmx = mode(n).q(ant(n).qml); % actual value
    ant(n).qms = sprintf('q_%.g max = %.3f @ t = %.2f',...
        n, mode(n).qmax, t(ant(n).qml)); % formated string
end
for d = 1:dof
    % location of umax
    ant(d).uml = find(abs(mode(d).u) == mode(d).umax); % location
    ant(d).umx = mode(d).u(ant(d).uml); % actual value
    ant(d).ums = sprintf('u_%.g max = %.3f @ t = %.2f',...
        d, mode(d).umax, t(ant(d).uml)); % formated string
end
%
% variables used to set variables
title_n = {'FontName','FontSize'};
title_v = {'Graphite Std', 22};
%
text_n = {'Interpreter','FontSize', 'Color'};
text_v = {'latex', 24,'#558B2F'};
%
label_n = {'FontName','FontSize'};
label_v = {'Hack', 18};
%
% set up figure
scrsz = get(groot, 'ScreenSize');
figure('Position', [.5*scrsz(3), .25*scrsz(4), 800, 600]);
tl = tiledlayout(2,1);
tl.TileSpacing = 'compact';
tl.Padding = 'compact';
title(tl, 'Modal Analysis', title_n, title_v);
% plot q vs time
pltqt = nexttile;
hold on
for n = 1:modes
    plot(pltqt, t, mode(n).q,'LineWidth', 2);
end
for n = 1:modes % done as separate loop to place arrows on top of line
    text(t(ant(n).qml), mode(n).q(ant(n).qml), ' \boldmath$\leftarrow$',...
        text_n, text_v);
end
hold off
patch(pltqt, [0 max(t)], [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
legend(pltqt, ant(1).qms, ant(2).qms); % must be done after the patch
grid(pltqt, 'on');
xlim([0 max(t)]);
% xlabel(pltqt, 'time, t (sec)');
ylim([-qmax*1.15 qmax*1.15]);
ylabel(pltqt, 'q');
%
% plot u vs time
pltut = nexttile;
hold on
for d = 1:dof
    plot(pltut, t, mode(d).u,'LineWidth', 2);
end
for d = 1:dof % done as separate loop to place arrows on top of line
    text(t(ant(d).uml), mode(d).u(ant(d).uml), ' \boldmath$\leftarrow$',...
        text_n, text_v);
end
hold off
patch(pltut, [0 max(t)], [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
% legend(pltut, ['u1 max = ' num2str(mode(1).umax)], ['u2 max = ' num2str(mode(2).umax)], ['u3 max = ' num2str(mode(3).umax)]);
legend(pltut, ant(1).ums, ant(2).ums);  % must be done after the patch
grid(pltut, 'on');
xlim([0 max(t)]);
xlabel(pltut, 'time, t (sec)');
ylim([-umax*1.15 umax*1.15]);
ylabel(pltut, 'displacement, u (in)');
