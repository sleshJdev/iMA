x0 = [0.5 1];
xmax = [20 20];
xmin = [-20 -20];
dx0 = [0.1 0.1];
y = rosenbrok(x0, 3, 3, -0.5, xmax, xmin, 0.075, dx0, @func1);
y
