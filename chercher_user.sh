#!/bin/bash
        for VM in "RAMDC1PCLPEG20D" "RAMDC1PCLPEG21D" "RAMDC1PCLBDD20D" "RAMDC1PCLBDD20Q" "RAMDC1PCLBDD21Q" "RAMDC1PCLPEG20Q" "RAMDC1PCLPEG21Q" "RAMDC1PCLPEG22Q" "RAMDC1PCLPEG23Q" "RAMDC1PCLPEG20I" "RAMDC1PCLPEG21I" "RAMDC1PCLPEG22I" "RAMDC1PCLPEG23I" "RAMDC1PCLPEG24I" "RAMDC1PCLBDD20I" "RAMDC1PCLBDD21I" "RAMDC1PCLPEG20P" "RAMDC1PCLPEG21P" "RAMDC1PCLPEG22P" "RAMDC1PCLPEG23P" "RAMDC1PCLPEG24P" "RAMDC1PCLPEG25P" "RAMDC1PCLPEG26P" "RAMDC1PCLPEG27P" "RAMDC1PCLBDD20P" "RAMDC1PCLBDD21P"
        do
                echo ---- $VM
                ssh $VM getent passwd | grep SVC
        done
~
