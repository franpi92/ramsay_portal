#!/bin/bash
########################################################################################
# Fichier deploy_centreon_scripts.sh
# Auteur : F.Dorn
########################################################################################

#LIST_VM="ramdc1pclpeg21i ramdc1pclpeg22i ramdc1pclpeg23i ramdc1pclbdd22i ramdc1pclbdd23i"
LIST_VM="ramdc1pclpeg21i ramdc1pclpeg22i ramdc1pclpeg23i ramdc1pclpeg24i"

#chmod 744  ~/.ssh
#cd ~/.ssh
#mv authorized_keys authorized_keys2
#ssh-keygen

for VM in $LIST_VM
do
	for FILE_CENTREON in `ls /home/sysadmin/scripts/centreon/*.sh`
	do
		echo ---- deploying $FILE_CENTREON on $VM
		scp $FILE_CENTREON sysadmin@$VM:/home/sysadmin/scripts/centreon
    done
done
~
