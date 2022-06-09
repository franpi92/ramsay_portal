#!/bin/ksh 
#
#PATH_SCRIPT="$(cd $(/usr/bin/dirname $(whence -- $0 || echo $0));pwd)"
PATH_SCRIPT=/home/sysadmin/scripts/sovich/
INFODIR=/home/sysadmin/scripts/sovich/tmp
DATE=$(date +"%d-%m-%y %H:%M:%S")
echo "Date $DATE"
echo $PATH_SCRIPT

echo $$ >$PATH_SCRIPT/.toptrace.pid

#cd $PATH_SCRIPT || exit 1
DAY=$(date +%d)
INFOFILE=top.$DAY
#cd $INFODIR
#if [ ! -f $INFOFILE ] ;then
#        rm top.today
#        ln -s $INFOFILE top.today
#fi
INTER=5
LIVE=false
[ "$1" = "--live" ] && LIVE=true && INTER=1
function print_start
{
        echo "------------------START $1 -------------------------------- $($PATH_SCRIPT/bin/mytime)">>$INFOFILE
}
function print_stop
{
        echo "------------------STOP $1 ---------------------------------" >>$INFOFILE
}
function print_cmd
{
        local CMD="$1" RES="$2"
        print_start "$CMD"
        echo "$2" >>$INFOFILE
        print_stop "$CMD"
}
function exec_cmd
{
        local CMD="$1"
        print_start "$CMD"
        eval "$CMD" >>$INFOFILE </dev/null
        print_stop "$CMD"
}
function iostat_filter {
        awk -v pathscript=$PATH_SCRIPT '
        BEGIN{
                maps=pathscript"/info.d/extra/multipath.maps";
                while(getline <maps >0)
                        for(i=2;i<=NF;i++) toskip[$i]=1;
                close(maps);
                dm=pathscript"/info.d/extra/dm.dev";
                while(getline <dm >0){
                        if ($0~/lvm/) lvmdev[$3]=$2; else miscdev[$3]=$2;
                }
                close(dm);
                n=0;
        }
        function dumplvm() {
                print "LVM:";
                for(i=0;i<n;i++) print lateprint[i];
                print "";
                delete lateprint;
                n=0;
        }
        /^Device:/{ if(n) dumplvm(); print ""; print; next }
        /^dm-/{
                sub("^dm-","",$1);
                if (!($1 in lvmdev)){
                        if ($1 in miscdev) $1=miscdev[$1]; else $1="dm-"$1; print; next;
                }
                $1=lvmdev[$1];
                lateprint[n++]=$0;
                next;
        }
        # Linux sometimes wraps line after device name.
        $1 !~ /^[0-9]/{
                if($1 ~/sd.[0-9]+$/) {next}             #remove partitions
                if($1 ~/cciss.c.d.p[0-9]+$/) {next}     #remove partitions
                if(!($1 in toskip)) print; next;
        }
        {print}
        END{ dumplvm() }
        '
}
function iostat {
        /usr/bin/iostat "$@" | iostat_filter
}
function ifinfo {
        for i in /sys/class/net/*
        do
                NIC=${i##*/}
                [ "$NIC" = "lo" ] && continue
                RX=$(cat $i/statistics/rx_bytes)
                TX=$(cat $i/statistics/tx_bytes)
                PXP=$(cat $i/statistics/rx_packets)
                TXP=$(cat $i/statistics/tx_packets)
                RXE=$(cat $i/statistics/rx_errors)
                TXE=$(cat $i/statistics/tx_errors)
                echo "$NIC $RX $TX $RXP $TXP $RXE $TXE"
        done
}
function cnx_count
{
    netstat -an |awk '
    $1=="tcp" {
         gsub("::ffff:","")
         gsub("::","")
         local=$4
         foreign=$5
         state=$6
         if(state!="LISTEN") {
          sub(":[^:]*$","",local)
          sub(":[^:]*$","",foreign)
         }
         nb[ local" "foreign" "state ]++
    }
    END{
        for(i in nb)
            print i, nb[ i ]
    }
'
}

trap "" INT TERM
echo "$(date +%d/%m/%Y\ %H:%M:%S) : TOPTRACE" >>$INFOFILE
echo "nbcpu:  $(grep -c processor /proc/cpuinfo)"  >>$INFOFILE
# ps ax -o pid,ppid,user,group,stime,time,s,pcpu,vsz,rss,comm,cmd,fname
exec_cmd "top -n 1 -b"
exec_cmd "awk '/^intr/{print \$1,\$2;next}{print}' /proc/stat"
exec_cmd "df -lPk -x smbfs -x tmpfs"
exec_cmd "cat /proc/vmstat"
exec_cmd "mpstat -P ALL $INTER 1"
exec_cmd "cat /proc/meminfo"
exec_cmd "ipcs -a"
exec_cmd "sar $INTER 1"
#whence ss >/dev/null && exec_cmd "ss -n" || exec_cmd "netstat -an"
# ss command causes bonding instability (link status definitely down for interface messages)
#exec_cmd "netstat -an"
exec_cmd "iostat -d"
exec_cmd "iostat -x -d $INTER 2"

whence ifconfig >/dev/null && exec_cmd "ifconfig -a"

exec_cmd "awk '\$3==\"nfs\"' /etc/mtab"

rm $PATH_SCRIPT/.toptrace.pid

