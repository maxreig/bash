#!/bin/sh
#
MACIAN=$(echo -e "\e[36m")         #COLOR MACIAN
MAGENT=$(echo -e "\e[35m")         #COLOR MAGENT
BLUE=$(echo -e "\e[34m")           #COLOR BLUE
YELLOW=$(echo -e "\e[33m")         #COLOR YELLOW
GREEN=$(echo -e "\e[32m")          #COLOR GREEN
RED=$(echo -e "\e[31m")            #COLOR RED
#
RESET=$(echo -e "\e[0m")           #RESET
#
# Banner CTTI debe ir en /etc/profile.d/ con el nombre dymotd.sh
#
clear
#
echo "############################################################################################################################# "
echo "                                                        "$RED"ALERT!                                                          "
echo " You are entering into a secured area! Your IP, Login Time.                                                                   "
echo " Username has been noted and has been sent to the server administrator!                                                       "
echo " This service is restricted to authorized users only. All activities on this system are logged.                               "
echo " Unauthorized access will be fully investigated and reported to the appropriate law enforcement agencies. $RESET              "
echo "############################################################################################################################# "
#
hard=$(dmidecode | grep -i "Manufacturer" | head -1 | awk '{print $1,$2}'| awk -F "," '{print $1}')
[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi
#
SO=$(printf "Welcome to $(cat /etc/redhat-release) $(uname -r)")
#
printf " Hostname = $(hostname | awk -F"." '{print $1}') \t\t Type = $hard \n"
printf " $SO \n"
echo "###################################################################################################################### "
printf "\n"
#
#System date
date=`date`
#
#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#Root fs info
root_usage=`df -h / | awk '/\// {print $4}'|grep -v "^$"`
fsperm=$(cat /proc/mounts | grep -i rootfs | awk '{print $4}' | awk -F"," '{print $1}')

#Memory Usage
memory_usage=`free -m | awk '/Mem:/ { total=$2 } /buffers\/cache/ { used=$3 } END { printf("%3.1f%%", used/total*100)}'`
swap_usage=`free -m | awk '/Swap/ { printf("%3.1f%%", $3/$2*100) }'`

#Users
users=`users | wc -w`
USER=`whoami`

#Processes
processes=`ps aux | wc -l`

if [[ $USER = "root" ]];then
        #Interfaces
        INTERFACE=$(ip -4 ad | grep 'UP' | awk -F ":" '!/^[0-9]*: ?lo/ {print $2}')
        #HBAs
        HBADEV=$(lspci | grep -i fibre | wc -l)
        #CLUSTER
        #CLU=$(chkconfig --list| grep cman | grep on| wc -l)
        if [[ $HBADEV -gt 0 ]];then
                if [[ -d /sys/class/fc_host ]];then
                        HBAS=$(ls /sys/class/fc_host)
                        HBATYPE=1
                elif [[ -d /proc/scsi/qla2xxx/ ]];then
                        HBAS=$(ls /proc/scsi/qla2xxx/)
                        HBATYPE=2
                else
                        echo "No Tiene HBA"
                fi
        else
                HBA=0
        fi
fi

echo "System information as of: $date"
echo
printf "System Load:\t%s %s %s\tSystem Uptime:\t\t%s "days" %s "hours" %s "min" %s "sec"\n" $LOAD1, $LOAD5, $LOAD15 $upDays $upHours $upMins $upSecs
printf "Memory Usage:\t%s\t\t\tSwap Usage:\t\t%s\n" $memory_usage $swap_usage
printf "Usage On /:\t%s\t\t\tAccess Rights on /:\t%s\n" $root_usage $fsperm
printf "Local Users:\t%s\t\t\tWhoami:\t\t\t%s\n" $users $USER
printf "Processes:\t%s\t\t\t\n" $processes

if [[ $USER = "root" ]];then
printf "\n"
printf "Interface\tMAC Address\t\tIP Address\t\n"

for x in $INTERFACE
do
        MAC=$(ip ad show dev $x |grep link/ether |awk '{print $2}')
        IP=$(ip ad show dev $x |grep -v inet6 | grep inet|awk '{print $2}')
        printf  $x"\t\t"$MAC"\t"$IP"\t"
        printf "\n"

done
echo
else
        echo
fi

printf "\n"
echo "--------------------------------------------------------------------------------"
printf "HBA\tNode_Name\t\tPort_Name\t\tState\t\tSpeed\t\n"
echo "--------------------------------------------------------------------------------"
if [[ $HBATYPE = 1 ]];then
        for HBA in $HBAS;do
        node=$(cat /sys/class/fc_host/$HBA/port_name)
        port=$(cat /sys/class/fc_host/$HBA/port_name)
        state=$(cat /sys/class/fc_host/$HBA/port_state)
        speed=$(cat /sys/class/fc_host/$HBA/speed)
        printf $HBA"\t"$node"\t"$port"\t"$state"\t\t"$speed"\t"
        printf "\n"
        done
        echo

elif [[ $HBATYPE = 2 ]];then
        for HBA in $HBAS;do
        node=$(grep adapter-node /proc/scsi/qla2xxx/$HBA | awk -F'=' '{print $2}')
        port=$(grep adapter-port /proc/scsi/qla2xxx/$HBA | awk -F'=' '{print $2}')
        state=$(grep -i "loop state" /proc/scsi/qla2xxx/$HBA | awk '{print $5}')
        printf $HBA"\t"$node"\t"$port"\t"$state"\t\t"
        printf "\n"
        done
        echo
else
        echo $RED"NO HBA ADAPTER" $RESET
        printf "\n"
fi

# FS NAS
#
        printf "\n\n"
echo "--------------------------------------------------------------------------------"
echo "FS NAS "
echo "--------------------------------------------------------------------------------"
        df -hT | grep -i "nfs" > /dev/null 2>&1
if [[ $? -eq 0 ]] ; then
	df -x "xfs" -x "tmpfs" -x "devtmpfs" -hTP
else
        echo $RED"NO NAS FS" $RESET

fi
#
if [[ $USER = "root" && $CLU -gt 0 ]];then
        clustat
else
        echo
fi

