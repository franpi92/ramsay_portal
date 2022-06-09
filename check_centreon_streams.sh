#!/bin/bash
# fichier check_centreon_streams.sh

			LISTE_SERVEURS=`cat /home/mobaxterm/servers_lists_marketing/servers_list_PPROD`
			for VM in $LISTE_SERVEURS
			do 
				echo "----$VM"; ssh -q sysadmin@$VM /bin/systemctl status snmpd.service | grep Active 
			done
#		else
#			echo fichier $FIC_LISTE_SERVEURS non trouvé
#		fi		
#	else
#		echo environnement $1 pas défini
#	fi
#fi
	