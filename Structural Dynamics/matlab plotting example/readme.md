Matlab Plotting with TiledLayout
================================

Terminology Used
----------------
(personal verbiage, not necessarily standard or exact)

- __String:__ 'text', a grouping of text considered to act as one, and is surrounded by either single or double quotes.
- __Vector:__ (matlab array) [# #] or [#, #], can hold numbers or strings, and is 1 x n in size.
- __Container:__ (matlab calls a figure), the larger box that will be containing all of the plots created.
- __Plot:__ (figure), typically a graph of some sort, and this will be placed inside the container. We will also use it to hold the text that is going to be printed.
- __Parent:__ higher-level element that contains lower level elements (ex: container).
- __Child:__ lower-level element that belongs to a higher-level element (ex: plot).
- __Variable:__ a string that is used to represent something

Defining Useful Variables
-------------------------

Start by creating variables to define the limits to be used by the graph axes

```
umax = max(abs(u));
fsmax = max(abs(fs));

umax_lim = umax * 1.15;
fsmax_lim = fsmax * 1.15;
fmax_lim = max(abs(ugdd)) * 1.15;
```

Defining the Container for the plots
------------------------------------

`scrsz` below is accessing what the computer resolution is set to. It will store four numbers: [start-x start-y width-x height-y]
 These numbers can be accessed by their position in the array, [1 2 3 4], by scrsz(#)

When defining the figure position it uses this same structure for the four variables. Below it is setting:
location start of x &rarr; 50% of scrsz width-x
location start of y &rarr; 25% of scrsz width-y
width in the x direction &rarr; 50% of scrsz width-x
height in the y direction &rarr; 75% scrsz width-y

```
scrsz = get(groot, 'ScreenSize');
figure('Position', [.5*scrsz(3) .25*scrsz(4) .5*scrsz(3) .75*scrsz(4)]);
```

You can skip using the screen size and just assign numbers directly to the plot. This will make it so that the plots will be the same no matter what computer or screen is being used.

```
figure('Position', [1 1 800 400]);
```

Below is using a newer method, starting R2019b, for defining multiple plots to be displayed together. `tl` is used to define the layout to make it easier for defining additional variables. This could be anything, but needs to be used consistently throughout.

- tiledlayout(#r, #c): The two numbers defines how many rows and columns should be in the layout respectively.
- tile spacing: controls the amount of space between the different plots.
- padding: controls the space between the plots and the exterior of the box.

Both spacing and padding have the option of 'normal', 'compact', or 'none'.

- title: requires to know first what you are labeling, `tl`, and then a string of the actual title.
    - putting title on the container will place it above the plot titles, and center it within the container.


```
tl = tiledlayout(2, 5);
tl.TileSpacing = 'compact';
tl.Padding = 'compact';
title(tl, 'Central Difference Method', 'FontSize', 16, 'FontWeight', 'bold');
```

Creating a Plot
---------------
Below will use Load vs Time plot as the example for explanation.

I first start by defining a variable that will contain a vector of the bottom and top limit of each axis. This is not required but since I use them in a couple of locations it makes it easier to keep them straight.

The variables that are used to hold these numbers can be named anything, I try and use terminology that associates the terms with the plot that they will be used for. If the plots get arranged at a later time frame then they will not need to get renamed.

```
plt_load_x = [0, max(t)];
plt_load_y = [-fmax_lim, fmax_lim];
```

Before anything else can be defined the plot itself has to be setup. As with the container, the variable name can be anything, or not used at all.

Next tile takes a vector with two numbers [#r, #c], which will also describe rows and columns but for the specific plot inside the container. _Notice that unlike the container, these are required to be inside brackets inside the parentheses._

The next line creates the first line that will be on the plot. Below is how the command is broken up: (parent, x, y,... additional modifications.)
- parent: which plot the line should be placed on
- x: the data that will be used on the x-axis
- y: the data that will be used on the y-axis
- linewidth: how thick the line should be
- color: what color the line should be

Matlab will automatically assign a line width and color, I use this for fine tuning the look of my output

- I sometimes place the main title on this plot in order to center it above the plots if I have the data on the right side (as shown further below). It would use the exact same syntax as above, but just would reference the plot as the parent instead.

```
pltld = nexttile([1 4]);
plot(pltld, t, ugdd, 'LineWidth', 2, 'Color', '#c62828');
```
Now we can fine tune this plot
- grid: to show the grid, the default is off, so it is only required if you want it on.
- xlim(parent, [start stop]):this sets the start and stop limits of the x axis. First we tell it which plot we are assigning it to, and then I use the variable I created above.
- xlabel(parent, label): what plot should be labeled, and then a string of what that label will be.
   - below I have the xlabel commented out since it will have the same label as the plot that will be below it and I only want it to show up once.
- ylim and ylabel, are the same as above except for the y-axis.
```
grid(pltld, 'on');
xlim(pltld, pltld_x);
% xlabel(pltld, 'time, t (s)');
ylim(pltld, pltld_y);
ylabel(pltld, 'load, f (k)');
```
<br>

__Bonus line for plot:__

Here I use patch to create a line along y=0. This is helpful for visualizing the data, since the grid is the same for all points. One benefit of using patch is that I can control the transparency of the line. _Technically this creates a rectangle and not a line_.
- patch(parent, [start-x stop-x], [start-y stop-y], color,... additional modifications)
    - here I use the same variable from the x-limit since it matches where I want the line to span.
    - since I want it to follow y = 0, then both the start and stop are 0.
    - edge alpha is set to 20% opacity (only required to create transparency)
    - line width, as before not required but helpful to make the plot more readable.

```
patch(pltld, pltld_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
```
There are other methods to create this line:
- line does not allow to alter transparency
```
line(pltld, pltld_x, [0, 0], 'k','LineWidth', 1);
```
- plot requires you to put a hold on then off on the plot in order to not overwrite the inital plot, and you are not able to modify the transparency.
```
hold on
plot(pltld, pltld_x, [0, 0], 'k','LineWidth', 1);
hold off
```
The hold method is necessary if you want to plot multiple lines on one graph.

Second Plot
-----------

Same as before but with different input.
```
pltut_x = [0 max(t)];
pltut_y = [-umax_lim, umax_lim];
pltut = nexttile([1 4]);
plot(pltut, t, u, 'LineWidth', 2, 'Color', '#1976d2');
grid(pltut, 'on');
xlim(pltut, pltut_x);
xlabel(pltut, 'time, t (sec)');
ylim(pltut, pltut_y);
ylabel(pltut, 'displacement, u (in)');
patch(pltut, pltut_x, [0, 0], 'k', 'EdgeAlpha', .2, 'LineWidth', 1);
```

Plot to Display Data
--------------------

I first start by defining the data I want to be shown, and how I want to show it. This time I will show the example before breaking it into the pieces.

```
print_left = strcat(...
sprintf('\n k =  %g', k),...
sprintf('\n m = %.2f', m),...
sprintf('\n $\\zeta$ = %g', zeta),...
sprintf('\n T = %.2f', T),...
sprintf('\n Fs = %.2f', Fs));
```

The first line is the name of the variable I used to hold the strings of data.
- strcat(...): just tells the program to concatenate the strings within the parentheses.
- sprintf(...): this states to format the data inside as a string when it is output
    - 'string'
        - \n: creates a new line at the beginning of each variable
        - x = : the regular text that will be output, used as a descriptor
        - %: This is a formatting operator that creates a placeholder for data that will be provided, and defines the format that it should be printed. There are many options but I typically only use 3 with some variations:
            - %f (fixed-point notation): I will use this when I want to limit how many places I want after the decimal point.
                - ex: $\pi$
                    - %f will use matlab default setting
                    - %.f &rarr; 3
                    - %.2f &rarr; 3.14
                    - %.25f &rarr; 3.1415926535897931159979635
            - %e (exponential notation): works the same as %f for decimal places, but provides the e+00 at the end for large/small numbers
                - ex: $\pi$
                    - %e will use matlab default setting
                    - %.e &rarr; 3
                    - %.2e &rarr; 3.14
                    - %.25e &rarr; 3.1415926535897931159979635


- In order to use the formatting above it requires the program to interpret the output as latex. Using latex does provide additional options for symbols. The `$  $` surrounding the text is the delineation of the latex script. Below are some options that we use:
    - `$\\zeta$` &rarr; &zeta;
    - `F$_s$` &rarr; F<sub>s</sub>
    - `$\\Delta$` &rarr; &Delta;
    - `$\\Delta t_{crit}$` &rarr; &Delta; t<sub>crit</sub>
    - `$u_{max}$` &rarr; u<sub>max</sub>
    - `$\\mu$` &rarr; &mu;
    - `$\\bar{\\omega}$` &rarr; <img src="https://latex.codecogs.com/svg.latex?\fn_jvn&space;\large&space;\sf{\bar{\omega}}" title="\large \sf{\bar{\omega}}" />
    - `$\\dot{\\omega}$` &rarr; <img src="https://latex.codecogs.com/svg.latex?\fn_jvn&space;\large&space;\sf{\dot{\omega}}" title="\large \sf{\dot{\omega}}" />
    - `$\\ddot{\\omega}$` &rarr; <img src="https://latex.codecogs.com/svg.latex?\fn_jvn&space;\large&space;\sf{\ddot{\omega}}" title="\large \sf{\ddot{\omega}}" />

_Notice: if you look up documentation about latex it will show it with only one slash `\` before the words, since matlab is reading it as code, it requires the second `\\` in order to tell it to read it as a slash._


## Final Plot
![Tiled Layout Matlab Resulting Plot](./Tl-ex.svg)

[File the produced plot](./TL-ex.m)
