#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}

modified_files = ""

depend() {
	after procfs
}

start() {
	ebegin "Copying relevant destkop files to $DEST_FOLDER"

	for src_folder in $SRC_FOLDERS ; do
		for desktop_file in ${src_folder}/* ; do
			if grep -q "Terminal=true" "$desktop_file" ; then
				sed -i "s/^Terminal=true/Terminal=false/;s/^Exec=/Exec=$TERMCMD /" $1
			fi
		done
	done

	modified_files = "a list"

	eend 0
}

stop() {
	ebegin "Removing desktop files from $DEST_FOLDER"
	
	echo $modified_files

	for src_folder in $SRC_FOLDERS ; do
		for desktop_file in ${src_folder}/* ; do
			if grep -q "Exec=$TERMCMD" "$desktop_file" ; then
				sed -i "/^Terminal=/d;s/^Exec=$TERMCMD /Exec=/" $1
			fi
		done
	done


	eend 0
}
