#!/bin/bash
echo "Etiqueta, followed by [ENTER]:"
read etiqueta 
echo "Lista, followed by [ENTER]:"
read lista 
echo "Inicio Contador, followed by [ENTER]:"
read CONTADOR
	echo "###############################################################################"
	echo "# Discos de DISKGROUP - $etiqueta - G"
	echo "###############################################################################"
for i in $(cat $lista)
do 	
	echo "	multipath {"
	echo "	wwid		$i"
	if [ $CONTADOR -le "9" ];then
		echo "	alias		$etiqueta"00$CONTADOR
	else
		echo "	alias		$etiqueta"0$CONTADOR
	fi
	echo "	}"
	printf "\n"
	let CONTADOR++
done
