update_i3_config:
	cd $(HOME)/.i3 && $(MAKE) && cd $(HOME)

mr_stat:
	mr -j 5 stat | most

mr_push:
	mr -j 5 push

mr_up:
	mr -j 5 update
