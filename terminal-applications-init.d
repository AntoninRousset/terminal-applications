#!/sbin/openrc-run
# Antonin Rousset
# Distributed under the terms of the GNU General Public License v3

description="Workaround of the bug that prevents desktop files to launch a terminal with Terminal=true"

: ${SRC_FOLDERS:="/usr/share/applications"}
: ${TERMCMD:="xterm -e"}

TERMINALS="${TERMINALS}|[aEkx]term|rxvt|gnome|konsole|interix|st|xterm"
TERMINAL_PARTS="${TERMINALS}|-\w*|\s"

depend() {
	need localmount
}

start() {
	for src_folder in ${SRC_FOLDERS} ; do
		ebegin "Changing destkop files in ${src_folder}"
		for desktop_file in "${src_folder}/"* ; do
			if grep -Eq "Terminal\s*=\s*true" "${desktop_file}" ; then
				sed -ri "s/^Terminal\s*=\s*true/Terminal=false/;s/^Exec\s*=(${TERMINAL_PARTS})*/Exec=${TERMCMD} /" "${desktop_file}"
			fi
		done
	done

	eend 0
}

stop() {
	for src_folder in $SRC_FOLDERS ; do
		ebegin "Reverting destkop files ${src_folder}"
		for desktop_file in "${src_folder}/"* ; do
			if grep -Eq "Exec\s*=\s*(${TERMINALS})" "${desktop_file}" ; then
				sed -ri "s/^Terminal\s*=\s*false/Terminal=true/;s/^Exec\s*=(${TERMINAL_PARTS})*/Exec=/" "${desktop_file}"
			fi
		done
	done

	eend 0
}
