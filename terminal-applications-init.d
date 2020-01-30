#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}

if [ "$TERMINALS" != "" ] ; then
	TERMINALS = "$TERMINALS|"
	echo $TERMINALS
fi
TERMINALS="$TERMINALS[aEkx]term -e|rxvt -e|gnome -e|konsole -e|interix -e|st -e"

depend() {
	need localmount
}

start() {

	for src_folder in $SRC_FOLDERS ; do
		ebegin "Changing destkop files in $src_folder"
		for desktop_file in "${src_folder}/"* ; do
			if grep -q "Terminal=true" "$desktop_file" ; then
				sed -i "s/^Terminal=true/Terminal=false/;/Exec=($terminals) /!s/^Exec=/Exec=$TERMCMD /" "$desktop_file"
			fi
		done
	done

	eend 0
}

stop() {
	for src_folder in $SRC_FOLDERS ; do
		ebegin "Reverting destkop files $src_folder"
		for desktop_file in "${src_folder}/"* ; do
			if grep -q "Terminal=false" "$desktop_file" ; then
				sed -ri "s/^Terminal=false/Terminal=true/;s/^Exec=($terminals) /Exec=/" "$desktop_file"
			fi
		done
	done

	eend 0
}
