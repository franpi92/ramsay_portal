#!/bin/ksh
# -----------------------------------------------------------------------------
# -- VERSION       : 1.1
# --
# -- AUTHOR        : SANGUA Clint on 20/02/2019
# -- UPDATED ON 29/04/2021
# --    Move directory /apps/pega/log to /apps/pega/log/ArchiveLogs
# --    Move file /apps/apache-tomcat-9.0.41/logs/catalina.out
# --            to directory /apps/apache-tomcat-9.0.41/logs/ArchiveLogs
# --    Logrotate 60 days LOG PEGA
# --    Logrotate 30 days LOG TOMCAT
# -- UPDATED ON 11/04/2022 by Sovichéa Vanny and François Dorn
# --    Previous archives were erased by function func_suppress_tomcat_files_after_backup
# --    because the function uses a recursive find to select files to be erased.
# --    And now only catalina.out, .txt and .log files are archived and compressed
# -- UPDATED ON 13/04/2022 by François Dorn
# --    Replace "-mtime +0" by "-mtime 0" and
# --    Replace "-or" by "-o" in order to include catalina.out during tar
# -- UPDATED ON 15/04/2022 by François Dorn
# --    Keep TOMCAT tar files during 60 days instead of 30
# -- REMARK :
# --    Agreed with Issam Rahimi and Rabii Mansour : we keep archiving 3 times/day
# --    in order to reduce the CPU load when the script runs
# --    (measured : 46% on 15/04/2022 at 6am on RAMDC1PCLPEG22P)
# -----------------------------------------------------------------------------


#---------------------------------------------------------- #
# LOAD . PROFILE
# --------------------------------------------------------- #
. /home/SVC_PCL_QUAL/.bash_profile

#---------------------------------------------------------- #
# LOAD VARIABLES
# --------------------------------------------------------- #
DATHOR=$(date +%Y-%m-%d_%H%M%S)
LOG_DIR_PEGA=/apps/pega/log
LOG_DIR_TOMCAT=/apps/apache-tomcat-9.0.41/logs
ARCHI_DIR_PEGA=/apps/pega/logs/ArchiveLogs
ARCHI_DIR_TOMCAT=/apps/apache-tomcat-9.0.41/logs/ArchiveLogs

#---------------------------------------------------------- #
# FUNCTIONS
# --------------------------------------------------------- #


func_create_archive_directory_pega()
{
           if [ -d  ${ARCHI_DIR_PEGA} ]
           then
           echo ${ARCHI_DIR_PEGA}
           else
           mkdir ${ARCHI_DIR_PEGA}
           fi
}

func_create_archive_directory_tomcat()
{
           if [ -d  ${ARCHI_DIR_TOMCAT} ]
           then
           echo ${ARCHI_DIR_TOMCAT}
           else
           mkdir ${ARCHI_DIR_TOMCAT}
           fi
}


func_save_pega_files()
{
           find ${LOG_DIR_PEGA} -daystart -mtime +0 -type f -name "*" -exec tar -cvzf ${ARCHI_DIR_PEGA}/SAV_APPS_PEGA_LOGS_${DATHOR}.tar.gz {} +
}

func_suppress_pega_files_after_backup()
{
           if [ -s  ${ARCHI_DIR_PEGA}/SAV_APPS_PEGA_LOGS_${DATHOR}.tar.gz ]
           then
           find ${LOG_DIR_PEGA} -daystart -mtime +0 -type f -name "*" -exec rm -rf {} +
           fi
}

func_save_tomcat_files()
{
           #find ${LOG_DIR_TOMCAT} -maxdepth 1 -daystart -mtime +0 -name "catalina.out" -or -name "localhost_access_log*" |xargs tar zcvf ${ARCHI_DIR_TOMCAT}/SAV_APPS_TOMCAT_LOGS_${DATHOR}.tar.gz ;
           find ${LOG_DIR_TOMCAT} -maxdepth 1 -daystart -mtime 0 -name "catalina.out" -o -name "localhost_access_log*" -o -name "*.log" |xargs tar zcvf ${ARCHI_DIR_TOMCAT}/SAV_APPS_TOMCAT_LOGS_${DATHOR}.tar.gz ;
}



func_suppress_tomcat_files_after_backup()
{
           if [ -s  ${ARCHI_DIR_TOMCAT}/SAV_APPS_TOMCAT_LOGS_${DATHOR}.tar.gz ]
           then
           #find ${LOG_DIR_TOMCAT} -maxdepth 1 -daystart -mtime +0 -type f -name "localhost_access_log*" | xargs rm -rf ;
           find ${LOG_DIR_TOMCAT} -maxdepth 1 -daystart -mtime 0 -type f -name "localhost_access_log*" -o -name "*.log" | xargs rm -rf ;
           fi
}

func_cleanup_catalina_file_after_backup()
{
           if [ -s  ${ARCHI_DIR_TOMCAT}/SAV_APPS_TOMCAT_LOGS_${DATHOR}.tar.gz ]
           then
           cat /dev/null > ${LOG_DIR_TOMCAT}/catalina.out
           fi
}


func_logrotate_X_days()
{
           #find ${ARCHI_DIR_TOMCAT} -mtime +30 -type f -name "*TOMCAT*" -exec rm -rf {} +
           find ${ARCHI_DIR_TOMCAT} -mtime +60 -type f -name "*TOMCAT*" -exec rm -rf {} +
           find ${ARCHI_DIR_PEGA} -mtime +60 -type f -name "*PEGA*" -exec rm -rf {} +
}



# ----------------------------
#   MAIN
# ----------------------------

func_create_archive_directory_pega
func_create_archive_directory_tomcat



# ----------------------------------------------------------------------
#   TAR PEGA AND TOMCAT LOG FILES; THEN SUPPRESS FILES
# ----------------------------------------------------------------------
func_save_pega_files
func_suppress_pega_files_after_backup
func_save_tomcat_files
func_suppress_tomcat_files_after_backup
func_cleanup_catalina_file_after_backup


# ----------------------------
#   LOGROTATE
# ----------------------------

func_logrotate_X_days
