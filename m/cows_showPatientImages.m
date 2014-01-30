function cows_showPatientImages(p, images)

DISPLAY_CURVES_WIDTH = 1;

if nargin < 2
	nImg = length(p.selected_pics);
	images = 1:nImg;
else
	nImg = length(images);
	if max(images) > length(p.selected_pics)
		fprintf('Invalid number of images.\n');
		return
	end
end

if nImg == 0
	fprintf('There is no images to show for this patient.\n');
	return
end

wid = 1.4;
colors = cows_colors;

fprintf('Patient: %d\n', p.id);

for k=1:nImg
	i = images(k);
	
	% Mostrar segmentacion
	fig = figure(329+k);
	clf
	set(fig, 'Position', [500+k*224,0,224,384])
	imshow(imread([p.path '/' p.tambo '/' p.selected_pics{i}]));
	hold on
	for j=1:length(p.control_points{i})
		plot(p.control_points{i}{j}(:,1), p.control_points{i}{j}(:,2), '.', 'color', colors{1});
		[xs, ys] = cows_closed_spline(p.control_points{i}{j}(:,1)',p.control_points{i}{j}(:,2)');
		plot(xs, ys, '--', 'color', 'y', 'Linewidth', wid);
	end
	text(10, 350, {strrep(p.selected_pics{i},'_','\_')}, 'color', 'y', 'FontSize', 13);
	hold off
	
	
	% Mostrar anchos
	if DISPLAY_CURVES_WIDTH
		fig2 = figure(229+k);
		clf
		set(fig2, 'Position', [500+k*224,384,224,384])
		cows_showEvolution(p,i);
	end
	
	% foco
	figure(329+k);
end