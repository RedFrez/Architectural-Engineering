clear
clc

% structure INPUT
k = 100;   % kip/in
m = 0.8;  % kip s^2/in
zeta = .1;

% initial conditions INPUT
q0 = 0;
qd0 = 0;

% calc structure parameters
Omega = sqrt(k/m);
OmegaD = Omega*sqrt(1-zeta^2);
T = 2*pi/Omega;

% calc response parameters
A = q0;
B = (qd0+(q0*zeta*Omega))/OmegaD;

% prepare time control (make vector with time)
del_t = 0.01;
max_t = 1.5;
t = 0:del_t:max_t;
j = (max_t/del_t)+1;

% loop thru time steps
for i = 1:j
    rad = OmegaD*t(i);
    q(i) = exp(-zeta*Omega*t(i))*(A*cos(rad)+B*sin(rad));
end
qmax = max(abs(q));
ymaxx = ceil(qmax * 1.15);

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
plot(pltld, t, qgdd, 'LineWidth', 2, 'Color', '#c62828');
grid(pltld, 'on');
patch(pltld, pltld_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
xlim(pltld, pltld_x);
ylim(pltld, pltld_y);
ylabel(pltld, 'load, f (k)');
title(tl, 'Central Difference Method', 'FontSize', 16, 'FontWeight', 'bold');

% plot displacement vs time
pltqt_x = [0 max(t)];
pltqt_y = [-qmax_lim, qmax_lim];
pltqt = nexttile([1 4]);
plot(pltqt, t, q, 'LineWidth', 2, 'Color', '#1976d2');
grid(pltqt, 'on');
xlim(pltqt, pltqt_x);
xlabel(pltqt, 'time, t (sec)');
ylim(pltqt, pltqt_y);
ylabel(pltqt, 'displacement, q (in)');
patch(pltqt, pltqt_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);

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
