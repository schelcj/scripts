AIDE_NODES="bajor,idran,denobula,nagios,nagios2,ns,puppet1,salt,syslog,vpn,www"
LOGIN_NODES="bajor,idran"
SLURM_NODES="cn0[01-32],denobula,bajor,idran"
COMPUTE_NODES="cn0[01-32]"
VIRT_NODES="backuppc,cobbler,dhcp,dns,gw,nagios,ns,puppet1,salt,syslog,vpn,www"
BIOSTAT_NODES="$(VIRT_NODES),$(SLURM_NODES)"

check_aide:
	pdsh -w $(AIDE_NODES) 'ps ax|grep aide && ls -la /var/lib/aide/aide.db'

update_aide:
	pdsh -l root -w $(AIDE_NODES) 'aideinit -f -y -b'

update_i3_config:
	cd $(HOME)/.i3 && $(MAKE) && cd $(HOME)

mr_stat:
	mr -j 5 stat | most

mr_push:
	mr -j 5 push

mr_up:
	mr -j 5 update

reload_puppet:
	pdsh -l root -w $(BIOSTAT_NODES) 'service puppet reload'
