clear
clc
%
% structure input
k = [562.97 -341.00 0; -341.00 568.33 -227.33; 0 -227.33 227.33];
m = [0.163 0 0; 0 0.163 0; 0 0 0.076];
l = [1; 1; 1];
zeta = .05;
Fs = 999999999999999;
%
% input ground motion
% file = 'el centro';
% file = 'loma prieta oakland harbor';
file = 'northridge sylmar NS';
A = xlsread(file);
t = A(:, 1);
ugdd = A(:, 2);
g = 386;
del_t = t(2) - t(1);
% input number of modes to be analyzed
modes = 3;
%
% mode shapes and freqs
[PHI,OMEGA2] = eig(k,m);
K = PHI'*k*PHI;
Omega = sqrt(OMEGA2);
dof = size(K,1);
Gamma = PHI.' * m * l;
%
% loop through modes
for n = 1:modes
    % calc structure parameters
    n_m = 1;
    n_k = K(n,n);
    n_omega = Omega(n,n);
    n_gamma = Gamma(n);
    n_c = zeta * (2 *n_m * n_omega);
    n_T = 2 * pi / n_omega;
    n_del_t_crit = n_T / pi;
    n_omegaD = n_omega * sqrt(1 - zeta^2);
    n_umax0 = Fs / n_k;
    % calc Central Diff parameters
    n_khat = n_m / (del_t^2) + n_c / (2 * del_t);
    n_a = n_m / (del_t^2) - n_c / (2 * del_t);
    n_b = 2 * n_m / del_t^2;
    % loop thru time steps for the mode
    for i = 1:(size(t,1)-1)
        mode(n).D(1) = 0;
        i_phat(1) = 0;
        mode(n).fs(1) = 0;
        i_base = 0;
        i = i + 1;
        mode(n).D(i) = i_phat(i - 1) / n_khat;
        if mode(n).D(i) > (i_base + n_umax0)
            i_base = mode(n).D(i) - n_umax0;
        elseif mode(n).D(i) < (i_base - n_umax0)
            i_base = mode(n).D(i) + n_umax0;
        end
        mode(n).fs(i) = n_k * (mode(n).D(i) - i_base);
        i_phat(i) = - g * ugdd(i) - n_a * mode(n).D(i-1) + n_b * mode(n).D(i) - mode(n).fs(i);
        mode(n).q(i) = n_gamma * mode(n).D(i);
    end
    % calculate the absolute max for q and fs to use later
    mode(n).qmax = max(abs(mode(n).q));
    mode(n).fsmax = max(abs(mode(n).fs));
end

% loop through modes for "processing"
% need to use all the mode values so must be done as a separate loop
for n = 1:dof
    u_temp = 0;
    for d = 1:dof
        u_temp = u_temp + PHI(n,d)*mode(d).q;
    end
    mode(n).u = u_temp;
    mode(n).umax = max(abs(mode(n).u));
end

qmax = max(vertcat(mode.qmax));
umax = max(vertcat(mode.umax));

% % bonus data for labeling of max on plots
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
% plot_n = {'LineWidth'};
% plot_v = {2};
%
text_n = {'Interpreter','FontSize', 'Color'};
text_v = {'latex', 24,'#558B2F'};
%
label_n = {'FontName','FontSize'};
label_v = {'Hack', 18};
%
colVal = {[0 0.4470 0.7410],...
         [0.8500 0.3250 0.0980],...
         [0.9290 0.6940 0.1250],...
         [0.4940 0.1840 0.5560],...
         [0.4660 0.6740 0.1880],...
         [0.3010 0.7450 0.9330]};
% set up figure
scrsz = get(groot, 'ScreenSize');
figure('Position', [.5*scrsz(3), .25*scrsz(4), 800, 600]);
tl = tiledlayout(2,1);
tl.TileSpacing = 'compact';
tl.Padding = 'compact';
title(tl, 'Modal Analysis of Northridge Earthquake', title_n, title_v);
%
% plot q vs time
pltqt = nexttile;
hold on
for n = 1:modes
    plot(pltqt, t, mode(n).q, 'Color', colVal{(n)});
end
for n = 1:modes % done as separate loop to place arrows on top of lines
    text(t(ant(n).qml), mode(n).q(ant(n).qml), ' \boldmath$\leftarrow$',...
        text_n, text_v, 'Color', colVal{(n)});
end
hold off
patch(pltqt, [0 max(t)], [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
legend(pltqt, ant(1).qms, ant(2).qms, ant(3).qms); % must be done after the patch
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
    plot(pltut, t, mode(d).u,  'Color', colVal{(d)});
end
for d = 1:dof % done as separate loop to place arrows on top of lines
    text(t(ant(d).uml), mode(d).u(ant(d).uml), ' \boldmath$\leftarrow$',...
        text_n, text_v, 'Color', colVal{(d)});
end
hold off
patch(pltut, [0 max(t)], [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
legend(pltut, ant(1).ums, ant(2).ums, ant(3).ums);  % must be done after the patch
grid(pltut, 'on');
xlim([0 max(t)]);
xlabel(pltut, 'time, t (sec)');
ylim([-umax*1.15 umax*1.15]);
ylabel(pltut, 'displacement, u (in)');
