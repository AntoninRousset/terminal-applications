#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}
: ${TMP_FOLDER:="/tmp/.applications"}

depend() {
	need localmount
}

start() {
	mkdir -p "$TMP_FOLDER"

	for src_folder in $SRC_FOLDERS ; do

		ebegin "Binding applications folder: $src_folder"
		mkdir -p "$TMP_FOLDER/$src_folder"
		cp -fr "$src_folder/"* "$TMP_FOLDER$src_folder"/
		mount -o bind "$TMP_FOLDER/$src_folder" "$src_folder"

	done

	ebegin "Changing destkop files"
	for src_folder in $SRC_FOLDERS ; do
		
		for desktop_file in "$TMP_FOLDER/$src_folder/"* ; do
			if grep -q "Terminal=true" "$desktop_file" ; then
				sed -i "s/^Terminal=true/Terminal=false/;/Exec=$TERMCMD /!s/^Exec=/Exec=$TERMCMD /" "$desktop_file"
			fi
		done
	done

	eend 0
}

stop() {
	ebegin "Reverting applications folders"

	for src_folder in $SRC_FOLDERS ; do

		umount -q $src_folder

	done
	rm -fr $TMP_FOLDER

	eend 0
}

