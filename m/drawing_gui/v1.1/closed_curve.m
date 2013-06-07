function [points,h1,h3] = closed_curve(path)

ultravacas_colors;

% im=imread(path);
% gcf = figure('menubar','none','tag','prueba','color',[87/255 86/255 84/255],'name','ULTRAVACAS','NumberTitle','off');
% imshow(im);

gcf

points = [];
tmp    = [];
pt     = zeros(2,1);
button = 1;

handleManual{1} = [];

while(button ~= 3)
	% 	keyboard
	[pt(1), pt(2), button] = ginput(1);
	if (isempty(points))
		points = [pt(1),pt(2)];
		hold on; h = plot(pt(1), pt(2), 'oy', 'linewidth', 2);
	else
		points(end+1,:) = [pt(1),pt(2)];
		if length(points(:,1)) < 3       % If there's only 2 points, display a line instead of spline
			hold on; h1 = plot(points(:,1),points(:,2),'--','color',colors{1},'Linewidth',2);
			tmp(end+1,:) = points(end,:);
			h2 = plot(tmp(:,1), tmp(:,2), 'y--', 'linewidth', 2);
		else
			[xs, ys] = closed_spline(points(:,1)',points(:,2)');
			
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
			
			hold on; h1 = plot(xs(1:idx),ys(1:idx),'--','color',colors{1},'Linewidth',2);
			hold on; h2 = plot(xs(idx:end),ys(idx:end),'y--','Linewidth',2);
		end
		if ( size(handleManual,2)>0 )
			for k=1:size(handleManual{1},1)
				delete(handleManual{1}(k));
			end
			handleManual(1)=[];
		end
		h3 = plot(points(:,1), points(:,2), 'oy', 'linewidth', 2);
		hold off;
		handleManual{1} = [h1;h2;h3];
	end
end

hold on;
h1 = plot(xs,ys,'--','color',colors{1},'Linewidth',2);
if ( size(handleManual,2)>0 )
	for k=1:size(handleManual{1},1)
		delete(handleManual{1}(k));
	end
	handleManual(1)=[];
end
delete(h);
h3 = plot(points(:,1), points(:,2), 'oy', 'linewidth', 2);
hold off;

% draw_closed_curve('sc.jpg',points);
end