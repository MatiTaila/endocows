function edit_curve(fname, point_id, fcn)

ultravacas_colors;
f=gcf;
hold on;
ud=get(f, 'UserData');

switch fcn
	case 0
		ud.mode = 'drag';
		ud.draggable = point_id;
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
			ud.control_points(ud.draggable,:) = p;
			
			t = findobj(f,'tag',[fname '_control_' num2str(ud.draggable)]);
			set(t,'XData',p(1)); set(t,'YData',p(2));
			
			if strcmp(ud.type, 'closed')
				[xs, ys] = closed_spline(ud.control_points(:,1)',ud.control_points(:,2)');
			else
				s_div = 1/10;
				tt = 1:size(ud.control_points, 1);
				ts = 1:s_div:size(ud.control_points, 1);
				xs = spline(tt,ud.control_points(:,1),ts);
				ys = spline(tt,ud.control_points(:,2),ts);
			end
			
			t = findobj(f,'tag',[fname '_interpolada']);
			set(t,'XData',xs); set(t,'YData',ys);
			set(f, 'UserData', ud);
		end
		return;
end