MR=mr -d $(HOME) -j 5

update_i3_config:
	cd $(HOME)/.i3 && $(MAKE) && cd $(HOME)

mr_stat:
	$(MR) stat | most

mr_push:
	$(MR) push

mr_up:
	$(MR) update

install-cpan-deps:
	$(HOME)/bin/cpanm --installdeps $(PWD)
