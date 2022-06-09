#!/bin/bash
# Fichier verif_systeme_Appli_Portal.sh
# dossier /home/sysadmin/scripts/francois/en_cours/surveillance
#DATE_FORMATEE=$(date "+%Y_%m%d_%H%M")
DATE_FORMATEE=$(date "+%Y_%m%d"):
FICHIER_RESULTAT=$DATE_FORMATEE"_resultats_systeme"
INTER=5
#####################################################################
function debut {
#####################################################################
	echo "------------ démarrage le "$(date "+%Y/%m/%d à %H:%M:%S")" de "$cmd >> $FICHIER_RESULTAT
}
#####################################################################
function fin {
#####################################################################
	echo "------------ fin à "$(date "+%Hh%M:%S")" de "$cmd >> $FICHIER_RESULTAT
}
#####################################################################
function exec_cmd_top {
#####################################################################
	cmd="top"
	debut
	top -n 1 -b  >> $FICHIER_RESULTAT
	fin
}
#####################################################################
function exec_cmd_vmstat {
#####################################################################
	cmd="vmstat"
	debut
	cat /proc/vmstat  >> $FICHIER_RESULTAT
	fin
}
#####################################################################
function exec_cmd_meminfo {
#####################################################################
	cmd="meminfo"
	debut
	cat /proc/meminfo  >> $FICHIER_RESULTAT
	fin
}
#####################################################################
function exec_cmd_sar {
#####################################################################
	cmd="sar"
	debut
	sar -u $INTER 2  >> $FICHIER_RESULTAT
	fin
}
#####################################################################
function exec_cmd {
#####################################################################
	cmd=$1
	debut
	bash -c $cmd >> $FICHIER_RESULTAT
	fin
}
#####################################################################
# DEBUT DU SCRIPT
#####################################################################
echo "============= Vérification du Système sur "$HOSTNAME" =============" >> $FICHIER_RESULTAT
exec_cmd_top
exec_cmd "df -lPk -x smbfs -x tmpfs"
exec_cmd_vmstat
exec_cmd "mpstat -P ALL $INTER 1"
exec_cmd_meminfo
exec_cmd "ipcs -a"
exec_cmd_sar
exec_cmd "iostat -d"
#####################################################################
# TODO
#####################################################################
##exec_cmd "awk '/^intr/{print \$1,\$2;next}{print}' /proc/stat"  | tee -a $FICHIER_RESULTAT
