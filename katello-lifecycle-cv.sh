#!/bin/bash
#
#
#########################################################################
# 		         ##  2018  ##                                   #
#  Script : update CV for REDHAT SATELLITE by HAMMER                    #
#########################################################################
# Color variables
#############################################################################
ORANGE=$(echo -e "\e[33m");				    # COLOR ORANGE
MACIAN=$(echo -e "\e[36m");    				# COLOR MACIAN
MAGENT=$(echo -e "\e[35m");    				# COLOR MAGENT
BLUE=$(echo -e "\e[34m");    				  # COLOR BLUE
YELLOW=$(echo -e "\e[33m");          	# COLOR YELLOW
GREEN=$(echo -e "\e[32m");           	# COLOR GREEN
RED=$(echo -e "\e[31m");             	# COLOR RED
WHITE=$(echo -e "\e[97m");				    # COLOR WHITE
BOLD=$(echo -e "\e[1m");				      # BOLD
BLINK=$(echo -e "\e[5mADMIN");				# BLINK
RESET=$(echo -e "\e[0m");				      # RESET
#
# Enviroment variables
#
# server=$(hostname -f)
#
# 0 - Se procede a borrar todos los archivos temporales
#
rm -f /tmp
#
# 1 - Send mail for information # start script
echo -e " Prueba # 1 " | mailx -s "Start to KATELLO script" max.reig.roig@es.ibm.com

# 2 - Update CV

# 3 - Promote CV

# 4 - Delete old(>3 versions) CV

# 5 - Send mail for information # stop script
exit 0
