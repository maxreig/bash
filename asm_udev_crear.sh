# @maxreig # 
#!/bin/sh
#
BASE=/filesgdba/scripts_oracle/asm/
FECHA=`date '+%Y%m%d'`-`date '+%H%M%S'`
LOGDIR="${BASE}/logs"
TMPDIR="${BASE}/tmp"
RULESDIR="${BASE}/rules"
MAQUINA=`hostname -s`
RULES="${RULESDIR}/99-asm.rules.generado.${FECHA}.${MAQUINA}"
#
FILTER=ORA-ASM
OWNER=orainfra
GROUP=asmadmin
DEST="asmdisk_udev"
#
TMPDISCOS="${TMPDIR}/$$.discos.asm"
#
if [ ! -d $BASE ]; then mkdir -p $BASE ; fi
if [ ! -d $LOGDIR ]; then mkdir -p $LOGDIR ; fi
if [ ! -d $TMPDIR ]; then mkdir -p $TMPDIR ; fi
if [ ! -d $RULESDIR ]; then mkdir -p $RULESDIR ; fi
#
echo "# Fichero de configuracion de dispositivos ASM para RHEL " > ${RULES}
echo "# OJO: cada linea KERNEL es una sola, que no se hagan dos! " >> ${RULES}
echo "#"  >> ${RULES}
echo "# Generado con asm_udev_crear.sh"  >> ${RULES}
echo "#"  >> ${RULES}
#
multipath -ll | grep ${FILTER} | sort > ${TMPDISCOS}
#
echo "Se han encontrado el siguiente numero de discos"
wc -l ${TMPDISCOS}
#
echo "Generando fichero ${RULES}"
while read disco
do
DISCO=$(echo $disco |  awk -F "(" ' { print $1 } '| awk -F "-" '{print $3}' | awk -F " " '{print $1}')
WWID=$(echo $disco |   awk -F "(" ' { print $2 } '| awk -F ")" ' { print $1  } ')
PARTITION=$(/sbin/partprobe -s -d /dev/mapper/${FILTER}-${DISCO} | /bin/grep -c partition)
#
if [[ $PARTITION == 1 ]];then
       echo "KERNEL==\"dm-*\", ENV{DM_UUID}==\"part1-mpath-${WWID}\", SYMLINK+=\"${DEST}/${DISCO}\", OWNER=\"${OWNER}\", GROUP=\"${GROUP}\", MODE=\"0660\"" >> ${RULES}
else
       echo "KERNEL==\"dm-*\", ENV{DM_UUID}==\"mpath-${WWID}\", SYMLINK+=\"${DEST}/${DISCO}\", OWNER=\"${OWNER}\", GROUP=\"${GROUP}\", MODE=\"0660\"" >> ${RULES}
fi
done < ${TMPDISCOS}
#
echo "Generado."
#
echo "Diferencias entre /etc/udev/rules.d/99-asm.rules y ${RULES}"
echo "--INI DIFF----------"
diff /etc/udev/rules.d/99-asm.rules ${RULES} | more
echo "--FIN DIFF----------"
#
# Selectivamente efectuamos la sustitucion del actual
#
NEXT=N
echo "Sustituir el fichero de reglas actual por el generado \(Y/N\)? [N]"
read NEXT
#
if [ "${NEXT}" == "Y" ]; then
#
echo "Preservamos una copia del actual"
        cp "/etc/udev/rules.d/99-asm.rules" "${RULESDIR}/99-asm.rules.productivo_anterior_a_${FECHA}.${MAQUINA}"

        # Escribimos encima
        cp ${RULES} /etc/udev/rules.d/99-asm.rules

        # Activar la configuracion: recargar reglas, flushear devices multipath, reactivar multipath => reaplica reglas
        udevadm control --reload
        udevadm trigger

else
        echo "Saliendo sin tocar la configuracion actual. Ejecutar las siguientes lineas para activarlo"
        echo
        echo "# Se debe preservar el fichero /etc/udev/rules.d/99-asm.rules actual"
        echo "# Se debe revisar el fichero ${RULES} y copiarlo a /etc/udev/rules.d/99-asm.rules"
        echo "cp ${RULES} /etc/udev/rules.d/99-asm.rules"
        echo "# Para activar la configuracion en RHEL se debe ejecutar:"
        echo "udevadm control --reload ; udevadm trigger"
fi
exit 0