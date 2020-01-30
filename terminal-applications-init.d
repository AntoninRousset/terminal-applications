#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}

depend() {
	need localmount
}

start() {
	ebegin "Changing destkop files $SRC_FOLDERS"

	for src_folder in $SRC_FOLDERS ; do
		for desktop_file in ${src_folder}/* ; do
			if grep -q "Terminal=true" "$desktop_file" ; then
				sed -i "s/^Terminal=true/Terminal=false/;/Exec=$TERMCMD /!s/^Exec=/Exec=$TERMCMD /" "$desktop_file"
			fi
		done
	done

	eend 0
}

stop() {
	ebegin "Reverting destkop files $SRC_FOLDERS"
	
	for src_folder in $SRC_FOLDERS ; do
		for desktop_file in ${src_folder}/* ; do
			if grep -q "Exec=$TERMCMD " "$desktop_file" ; then
				sed -i "s/^Terminal=false/Terminal=true/;s/^Exec=$TERMCMD /Exec=/" "$desktop_file"
			fi
		done
	done


	eend 0
}

