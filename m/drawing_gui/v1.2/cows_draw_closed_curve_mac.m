function [points, h_curve, h_points] = cows_draw_closed_curve_mac(curve_id)

wid = 1;

ultravacas_colors;
gcf;

points = [];
tmp    = [];
pt     = zeros(2,1);
button = 1;

handleManual{1} = [];

while(button ~= 3)
	[pt(1), pt(2), button] = myginput(1,'crosshair');
	if button == 3
		break;
	end
	if (isempty(points))
		points = [pt(1),pt(2)];
		hold on; h = plot(pt(1), pt(2), 'oy', 'linewidth', wid);
	else
		points(end+1,:) = [pt(1),pt(2)];
		if length(points(:,1)) < 3       % If there's only 2 points, display a line instead of spline
			hold on; h1 = plot(points(:,1),points(:,2),'--','color',colors{1},'Linewidth', wid);
			tmp(end+1,:) = points(end,:);
			h2 = plot(tmp(:,1), tmp(:,2), 'y--', 'linewidth', wid);
		else
			[xs, ys] = cows_closed_spline(points(:,1)',points(:,2)');
			
			% Find the position of the last (fin) and first (deb) points of fd.points in xs and ys
			fin = find((xs == points(end,1)) & (ys == points(end,2)) );
			deb = find((xs == points(1,1)) & (ys == points(1,2)) );
			
			% Change the point order to have deb->fin->deb
			xs = xs([deb:end, 1:deb]);          ys = ys([deb:end, 1:deb]);
			if deb > fin            % And compute the new position of the last point
				idx = length(xs) + fin - deb;
			else
				idx = fin - deb;
			end
			clear deb fin;
			
			hold on; h1 = plot(xs(1:idx),ys(1:idx),'--','color',colors{1},'Linewidth', wid);
			hold on; h2 = plot(xs(idx:end),ys(idx:end),'y--','Linewidth', wid);
		end
		if ( size(handleManual,2)>0 )
			for k=1:size(handleManual{1},1)
				delete(handleManual{1}(k));
			end
			handleManual(1)=[];
		end
		h3 = plot(points(:,1), points(:,2), 'oy', 'linewidth', wid);
		hold off;
		handleManual{1} = [h1;h2;h3];
	end
end

hold on;
h1 = plot(xs,ys,'--','color',colors{1},'Linewidth',wid);
if ( size(handleManual,2)>0 )
	for k=1:size(handleManual{1},1)
		delete(handleManual{1}(k));
	end
	handleManual(1)=[];
end
delete(h);
% h3 = plot(points(:,1), points(:,2), 'oy', 'linewidth', wid);
% hold off;



str = [get(gcf,'tag') '_interpolada_' curve_id];
set(h1,'tag',str);	

h_points=zeros(size(points,1),1);
for i=1:size(points,1)
	h_points(i) = plot(points(i,1), points(i,2), 'oy', 'linewidth', wid);
	set(h_points(i),'tag',[get(gcf,'tag') '_control_' num2str(curve_id) '_' num2str(i)]);
	set(h_points(i),'ButtonDownFcn',['cows_edit_closed_curve(''' char(get(gcf,'tag')) ''',' num2str(curve_id) ',' num2str(i) ', 0)']);
end

h_curve = h1;

end