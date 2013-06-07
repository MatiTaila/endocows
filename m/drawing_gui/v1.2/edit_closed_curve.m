function edit_closed_curve(fname, curve_id, point_id, fcn)

ultravacas_colors;
f=gcf;
hold on;
ud=get(f, 'UserData');

switch fcn
	case 0
		ud.mode = 'drag';
		ud.draggable = point_id;
		
		p = get(gca,'CurrentPoint'); p = [p(1,1) p(1,2)];
		
		d_curves = zeros(curve_id, 1);
		for i=1:curve_id
			d=[ud.control_points{i}(:,1)-p(1) ud.control_points{i}(:,2)-p(2)];
			norm = d(:,1).^2+d(:,2).^2;
			d_curves(i) = min(norm);
		end
		curr_curve = find(d_curves==min(d_curves));
		curr_curve = curr_curve(1);
		
		ud.curr_curve = curr_curve;
		
		set(f, 'UserData', ud);
		return;
	case 1
		ud.mode = 'normal';
		ud.draggable = 0;
		set(f, 'UserData', ud);
		return;
	case 2
		if strcmp(ud.mode ,'drag')
			
			p = get(gca,'CurrentPoint'); p = [p(1,1) p(1,2)];
				
			ud.control_points{ud.curr_curve}(ud.draggable,:) = p;
			
			t = findobj(f,'tag',[fname '_control_' num2str(ud.curr_curve) '_' num2str(ud.draggable)]);
% 			keyboard
			set(t,'XData',p(1)); set(t,'YData',p(2));
			
			[xs, ys] = closed_spline(ud.control_points{ud.curr_curve}(:,1)',ud.control_points{ud.curr_curve}(:,2)');
			t = findobj(f,'tag',[fname '_interpolada_' ud.curr_curve]);
			set(t,'XData',xs); set(t,'YData',ys);
			set(f, 'UserData', ud);
		end
		return;
end