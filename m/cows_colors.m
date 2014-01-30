function colors = cows_colors(visualize)

colors(1)={[243, 132, 0]/256};   % orange1
colors(2)={[166, 166, 166]/256}; % silver1
colors(3)={[154,205,50]/256};    % green1
colors(4)={[34,139,34]/256};     % green2
colors(5)={[0,0,128]/256};       % blue1
colors(6)={[0,0,255]/256};       % blue2
colors(7)={[100 149 237]/256};   % blue3
colors(8)={[255,0,0]/256};       % red1
colors(9)={[178,34,34]/256};     % red2
colors(10)={[165,136,105]/256};  % red3

if exist('visualize','var')
	figure
	for i=1:length(colors)
		line([0 10],[i i ], 'linewidth', 20, 'color', colors{i});
	end
	axis([0 10 0 i+1])
end
