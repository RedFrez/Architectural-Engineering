clear
clc

% structure INPUT
k = 406.74;   % kip/in
m = 0.7619;  % kip s^2/in
zeta = .05;

% initial conditions INPUT
u0 = 0;
ud0 = 5.0;

% calc structure parameters
Omega = sqrt(k/m);
OmegaD = Omega*sqrt(1-zeta^2);
T = 2*pi/Omega;

% calc response parameters
A = u0;
B = (ud0+(u0*zeta*Omega))/OmegaD;

% prepare time control (make vector with time)
del_t = 0.01;
max_t = 1.5;
t = 0:del_t:max_t;
j = (max_t/del_t)+1;

% loop thru time steps
for i = 1:j
    rad = OmegaD*t(i);
    u(i) = exp(-zeta*Omega*t(i))*(A*cos(rad)+B*sin(rad));
end
umax = max(max(u),-min(u));
ymaxx = round(umax * 1.25,2);

% set up figure with plot and output block
scrsz = get(groot,'ScreenSize');
figure('Position',[.5*scrsz(3) .25*scrsz(4) 1000 400]);

% plot displ vs time
% Define lines to be placed on the plot
plot(t,u, 'LineStyle','-','LineWidth',3,'Color','#2196f3');
% Define properties for the plot
xlabel('time (sec)');
xlim([0 max(t)]);
ylabel('displacement, u (in)');
ylim([-ymaxx ymaxx]);
legend('u');
grid on
set(gca, 'fontsize', 10);

% Define the strings to label input variables
% \\quad is used to add (4) spaces before each variable
str_ip = sprintf('Input:');
str_k = sprintf('$\\quad$ k = %g', k);
str_m = sprintf('$\\quad$ m = %g', m);
str_zeta = sprintf('$\\quad \\zeta$ = %g', zeta);
str_u0 = sprintf('$\\quad u_{0}$ = %g', u0);
str_ud0 = sprintf('$\\quad \\dot{u{_0}}$= %g', ud0);
% Define strings to label the computed variables
str_cp = sprintf('Computed:');
str_On = sprintf('$\\quad \\omega$ = %.3f', Omega);
str_Od = sprintf('$\\quad \\omega_{d}$ = %.3f', OmegaD);
str_T = sprintf('$\\quad$ T = %.3f', T);
str_umax = sprintf('$\\quad u_{max}$ =  %.3f', umax);

% add variables to title of plot
title({
    (strcat(str_ip, str_k, str_m, str_zeta, str_u0, str_ud0))
    (strcat(str_cp, str_On, str_Od, str_T, str_umax))
    },'Interpreter','latex', 'fontsize', 16)
