function [xs, ys] = closed_spline(x, y)
%-- "Looping" the points to have a nice closed contour
i = 7;      %-- Number of extra points added
if length(x) > i       %-- Check if the number of point is sufficient
	x = [x x(1:i)];     y = [y y(1:i)];
else
	i2 = i-length(x);
	x = [x x];          y = [y y];
	x = [x x(1:i2)];    y = [y y(1:i2)];
end

s_div = 1/10;
t = 1:length(x);
ts = 1:s_div:length(x);

xs = spline(t,x,ts);
ys = spline(t,y,ts);

%-- Deleting the extra segment (at the begining and at the end)
xs = xs(ceil(i/2)/s_div:(length(x)-floor(i/2))/s_div);
ys = ys(ceil(i/2)/s_div:(length(x)-floor(i/2))/s_div);
end