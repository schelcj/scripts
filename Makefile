AIDE_NODES=bajor,idran,denobula,nagios,nagios2,ns,puppet1,syslog,vpn,www
LOGIN_NODES=bajor,idran
COMPUTE_NODES=cn0[01-18,20-34]
SLURM_NODES=$(LOGIN_NODES),$(COMPUTE_NODES),denobula
VIRT_NODES=backuppc,cobbler,dhcp,dns,gw,nagios,ns,puppet1,regula,syslog,vpn,www,xfer
BIOSTAT_NODES=$(VIRT_NODES),$(SLURM_NODES),nagios2

all_nodes:
	pdsh -l root -w "$(BIOSTAT_NODES)"

cluster_nodes:
	pdsh -l root -w "$(SLURM_NODES),$(LOGIN_NODES)"

virt_nodes:
	pdsh -l root -w "$(VIRT_NODES)"

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

restart_ganglia:
	pdsh -l root -w $(COMPUTE_NODES) 'service ganglia-monitor restart'

restart_slurm:
	pdsh -l root -w $(SLURM_NODES) 'service slurm restart'

start_nctopd:
	pdsh -l root -w $(COMPUTE_NODES) 'pidof nctopd || /home/software/lucid/nctop/0.23.2/sbin/nctopd -d -u nobody -w 5'

check_restart_required:
	pdsh -w $(BIOSTAT_NODES) "grep 'System restart required' /etc/motd"
