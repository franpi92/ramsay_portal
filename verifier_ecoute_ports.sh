#!/bin/bash
# fichier verifier_ecoute_ports.sh
echo ---------- "Vérification des tâches d'écoute sur lesports dans $1"
for VM in `cat ~/liste_serveurs_$1`; do echo $VM; ssh $VM sudo ps -ef | grep -w nc done
