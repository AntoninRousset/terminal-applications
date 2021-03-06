#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}

if [ "${TERMCMDS}" != "" ] ; then
	TERMCMDS="${TERMCMDS}|"
fi
TERMCMDS="${TERMCMDS}[aEkx]term -e|rxvt -e|gnome -e|konsole -e|interix -e|st -e|xterm -e"

terminal_cmds=$(echo "${TERMCMDS}" | sed -r "s/\|/(\\\s|-\w*)*\|/g;s/\s/(\\\s|-\w*)*/g")
terminal_parts=$(echo "${TERMCMDS}" | sed -r "s/(\s|-\w*)//g")"|-\w*|\s"

depend() {
	need localmount
}

start() {
	if ! echo "${TERMCMD}" | grep -Eq "(${terminal_cmds})" ; then
		eend 1 "\"${TERMCMD}\" is not part of \"${TERMCMDS}\", please add it to TERMCMDS"
		exit 1
	fi

	for src_folder in ${SRC_FOLDERS} ; do
		ebegin "Changing destkop files in ${src_folder}"
		for desktop_file in "${src_folder}/"* ; do
			if grep -Eq "Terminal\s*=\s*true" "${desktop_file}" ; then
				sed -ri "s/^Terminal\s*=\s*true/Terminal=false/;s/^Exec\s*=(${terminal_parts})*/Exec=${TERMCMD} /" "${desktop_file}"
			fi
		done
	done

	xdg-desktop-menu forceupdate

	eend 0
}

stop() {
	for src_folder in $SRC_FOLDERS ; do
		ebegin "Reverting destkop files in ${src_folder}"
		for desktop_file in "${src_folder}/"* ; do
			if grep -Eq "Exec\s*=\s*(${terminal_cmds})" "${desktop_file}" ; then
				sed -ri "s/^Terminal\s*=\s*false/Terminal=true/;s/^Exec\s*=(${terminal_parts})*/Exec=/" "${desktop_file}"
			fi
		done
	done

	xdg-desktop-menu forceupdate

	eend 0
}
