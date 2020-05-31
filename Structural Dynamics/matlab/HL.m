clear
clc
%
% structure INPUT
k = 410;   % kip/in
w = 130;  % kip
zeta = .05;
m = w / 386;
%
% describe harmonic loading with amplitude and freq
p0 = w * 0.18; % kip 0.18 * weight
OmegaBar = 31.4; % rad/s
%
% calc  parameters
Omega = sqrt(k/m);
OmegaD = Omega*sqrt(1-zeta^2);
T = 0.2; % length of sin wave
beta = OmegaBar/Omega;
%
% prepare time control (make vector with time)
del_t = 0.01;
max_t = 2;
t = 0:del_t:max_t;
j = (max_t/del_t)+1;
%
% create breaks for different time sections
max_th = 0.1;
jh1 = (max_th/del_t)+1;
jh2 = ((max_th*2)/del_t) +1;
%
% create data points for first impulse
for i = 1:j
    if i < jh1
        f1(i) = (0.18*w) * sin(OmegaBar*t(i));
    else
        f1(i) = 0;
    end
end
% create data points for second impulse for plotting
for i = 1:j
    if i < jh1
        f2(i) = 0;
    elseif (jh1 <= i) && (i < jh2)
        f2(i) = (0.18*w) * sin(OmegaBar*t(i));
    else
        f2(i) = 0;
    end
end
u0 = 0;
uf1 = trapz(del_t, f1); % calculate integral of first force
ud1 = uf1/m; % convert integral to velocity
%
% create data points for Free Vibration of first impulse
for i = 1:j
    A = u0;
    B = (ud1+(u0*zeta*Omega))/OmegaD;
    rad = OmegaD*t(i);
    u1(i) = exp(-zeta*Omega*t(i))*(A*cos(rad)+B*sin(rad));
end
%
% create data points for free vibration of second impulse
ud2 = -ud1; % make starting impulse negative
for i = 1:j
    if i < jh1
      u2(i) = 0;
    else
      i2 = (i-jh1+1);
      A = u0;
      B = (ud2+(u0*zeta*Omega))/OmegaD;
      rad = OmegaD*t(i2);
      u2(i) = exp(-zeta*Omega*t(i2))*(A*cos(rad)+B*sin(rad));
    end
end
% add data from the two free vibrations together to get overall response
utot = u1 + u2;
% 
% calculate maximum displacements
u1max = max(abs(u1));
u2max = max(abs(u2));
umax = max(abs(utot));
ymax = (umax * 1.15);
%
% set up figure with plot and output block
scrsz = get(groot,'ScreenSize');
figure('Position',[.5*scrsz(3) .25*scrsz(4) 1200 700]);
tiledlayout(3,3);
%
%  create first plot to show displacement comparison data
plt1 = nexttile([2,3]);
plot(plt1, t, utot, 'LineStyle','-','LineWidth',2,'Color','#0072BD');
hold on
plot(plt1, t, u1, 'LineStyle','--','LineWidth',1,'Color', '#D95319');
plot(plt1, t, u2, 'LineStyle','-.','LineWidth',1,'Color',	'#77AC30');
hold off
% Define properties for the plt1 area
xlim(plt1, [0 max_t]);
ylim(plt1, [-ymax ymax]);
grid(plt1, 'on')
title(plt1, 'Displacement vs Time', 'FontSize', 16)
xlabel(plt1, 'time, t (sec)')
ylabel(plt1, 'displatement, u (in)')
legend(plt1, 'u_{total}', 'u_1', 'u_2');
%
% create second plot to show both impulse force data
plt2 = nexttile([1,2]);
plot(plt2, t, f1, 'LineStyle','-','LineWidth',1.5,'Color',	'#7E2F8E');
hold on
plot(plt2, t, f2, 'LineStyle','-','LineWidth',1.5,'Color', '#4DBEEE');
hold off
% Define properties for the plt2 area
xlim(plt2, [0 max_t*.60]);
grid(plt2, 'on')
title(plt2, 'Force vs Time', 'FontSize', 16)
xlabel(plt2, 'time, t (sec)')
ylabel(plt2, 'force, f (k)')
legend(plt2, 'First Impulse', 'Second Impulse');
%
% Define the strings to label input variables to be displayed
str_k = sprintf('\n k = %g', k);
str_m = sprintf('\n m = %.2f', m);
str_zeta = sprintf('\n $\\zeta$ = %g', zeta);
str_Ob = sprintf('\n $\\omega_{bar}$ = %g', OmegaBar);
str_Om = sprintf('\n $\\omega$ = %g', Omega);
str_Omd = sprintf('\n $\\omega_{d}$ = %g', OmegaD);
str_T = sprintf('\n T = %.2f', T);
str_umax = sprintf('\n $u_{max}$ =  %.2f', umax);
str_u1max = sprintf('\n $u_{1max}$ =  %.2f', u1max);
str_u2max = sprintf('\n $u_{2max}$ =  %.2f', u2max);
%
% split the variables into two columns to be displayed
str_l = strcat(str_k, str_m, str_zeta, str_Ob, str_Om, str_Omd, str_T);
str_r = strcat(str_umax, str_u1max, str_u2max);
%
% create "plot" to hold text output
plt3 = nexttile;
plt3.FontSize = 14;
title(plt3, 'Data')
xticks(plt3, [])
yticks(plt3, [])
box(plt3,'on')
pos = [.05 .95];
xlabel(plt3, {str_l}, 'Units', 'normalized', 'Position', pos,...
 'Interpreter','latex', 'verticalalignment', 'top',...
 'horizontalalignment','left');
pos2 = [.55 .95];
ylabel(plt3, {str_r}, 'Units', 'normalized', 'Position', pos2,...
 'Interpreter','latex', 'verticalalignment', 'top',...
 'horizontalalignment','left', 'rotation',0);
