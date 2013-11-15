load('cows_cfg');
 for i=1:length(patients)
	 p = patients(i);
	 cows_showPatientImages(p)
	 keyboard
	 set(figure(330),'visible','off');
	 set(figure(331),'visible','off');
 end