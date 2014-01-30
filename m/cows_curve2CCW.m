function ccwCurve = cows_curve2CCW(curve)
points = zeros(size(curve));
N	   = size(curve,1);
for i=1:N
	left = i-1;	if left==0, left = N; end
	right = i+1; if right>N, right = 1; end
	n = [-(curve(right,2)-curve(left,2)), curve(right,1)-curve(left,1)];
	n = n/norm(n);
	points(i,:) = curve(i,:)+n*0.1;
end
if median(double(inpolygon(points(:,1), points(:,2), curve(:,1), curve(:,2))));
	ccwCurve = curve;
else
	ccwCurve = flipud(curve);
end
