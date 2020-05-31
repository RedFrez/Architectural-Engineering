clear % clears variables
clc % clears command line

% structure input
k = 100;
m = .5;
zeta = .05;
Fs = 80;

% input ground motion
file = 'el centro';
%file = 'loma prieta oakland harbor';
%file = 'northridge sylmar NS';
A = xlsread(file);
t = A(:, 1);
ugdd = A(:, 2);
g = 386;
del_t = t(2) - t(1);

% calc structure parameters
omega = sqrt(k / m);
c = zeta * (2 * m * omega);
T = 2 * pi / omega;
del_t_crit = T / pi;
omega_d = omega * sqrt(1 - zeta^2);
umax0 = Fs / k;

% calc Central Diff parameters
khat = m / del_t^2 + c / (2 * del_t);
a = m / del_t^2 - c / (2 * del_t);
b = 2 * m / del_t^2;

% prepare loop
i = 1;
u(i) = 0;
phat(i) = 0;
fs(i) = 0;
base = 0;
% loop thru time steps
while t(i) < max(t)
    i = i + 1;
    u(i) = phat(i - 1) / khat;

    if u(i) > (base + umax0)
        base = u(i) - umax0;
    elseif u(i) < (base - umax0)
        base = u(i) + umax0;
    end

    fs(i) = k * (u(i) - base);
    phat(i) = -m * g * ugdd(i) - a * u(i - 1) + b * u(i) - fs(i);
end

umax = max(abs(u));
umax_lim = umax * 1.15;
fsmax = max(abs(fs));
fsmax_lim = fsmax * 1.15;
fmax_lim = max(abs(ugdd)) * 1.15;
umax0 = Fs / k;
mu = umax / umax0;

% set up figure
scrsz = get(groot, 'ScreenSize');
figure('Position', [.5*scrsz(3), .25*scrsz(4), 900, 500]);

tl = tiledlayout(2, 5);
tl.TileSpacing = 'compact';
tl.Padding = 'compact';

% plot load
pltld_x = [0 max(t)];
pltld_y = [-fmax_lim, fmax_lim];
pltld = nexttile([1 4]);
plot(pltld, t, ugdd, 'LineWidth', 1, 'Color', '#c62828');
grid(pltld, 'on');
patch(pltld, pltld_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
xlim(pltld, pltld_x);
ylim(pltld, pltld_y);
ylabel(pltld, 'load, f (k)');
title(tl, 'Central Difference Method', 'FontSize', 16, 'FontWeight', 'bold');

% plot displacement vs time
pltut_x = [0 max(t)];
pltut_y = [-umax_lim, umax_lim];
pltut = nexttile([1 4]);
plot(pltut, t, u, 'LineWidth', 1, 'Color', '#1976d2');
grid(pltut, 'on');
xlim(pltut, pltut_x);
xlabel(pltut, 'time, t (sec)');
ylim(pltut, pltut_y);
ylabel(pltut, 'displacement, u (in)');
patch(pltut, pltut_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);

% Define the strings to label input variables
% left column
print_left = strcat(...
sprintf('\n k =  %g', k),...
sprintf('\n m = %.2f', m),...
sprintf('\n $\\zeta$ = %g', zeta),...
sprintf('\n T = %.2f', T),...
sprintf('\n Fs = %.2f', Fs));
% right column if needed.
% print_right = strcat(...
% sprintf(' ', ));

% create plot to hold data
pltd = nexttile([2, 1]);
pltd.FontSize = 12;
title(pltd, 'Data')
box(pltd, 'on')
xticks(pltd, [])
yticks(pltd, [])
% for left column printing
pos = [.05 .98];
xlabel(pltd, {print_left}, 'Units', 'normalized', 'Position', pos, ...
    'Interpreter','latex','verticalalignment', 'top', ...
    'horizontalalignment', 'left');

% if using right column for printing
% pos2 = [.5 .98];
% ylabel(pltd, {print_right}, 'Units', 'normalized', 'Position', pos2, ...
%     'Interpreter', 'latex', 'verticalalignment', 'top', ...
%     'horizontalalignment', 'left', 'rotation', 0);
