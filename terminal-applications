#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications/"}
: ${DEST_FOLDER:="/home/antonin/.local/share/applications/"}
: ${TERMCMD:="xterm -e"}

depend() {
	after procfs
}

start() {
	ebegin "Copying relevant destkop files to $DEST_FOLDER"

	create_file() {
		name=$(basename $1)
		sed "/^Terminal=/d;s/^Exec=/Exec=$TERMCMD /" $1 > ${DEST_FOLDER}$name
	}

	for src_folder in $SRC_FOLDERS ; do
		for desktop_file in ${src_folder}/* ; do
			if grep -q "Terminal=true" "$desktop_file" ; then
				create_file $desktop_file
			fi
		done
	done

	eend 0
}

stop() {
	ebegin "Removing desktop files from $DEST_FOLDER"
	
	for desktop_file in ${DEST_FOLDER}/* ; do
		if grep -q "Exec=$TERMCMD" "$desktop_file" ; then
			echo $desktop_file
			rm $desktop_file
		fi
	done


	eend 0
}
