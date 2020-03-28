#!/bin/sh
usage() {
cat << EOF
usage: $0 [-i input]
	-i input
EOF
}

while getopts ":i:" o; do
	case "${o}" in
		i)
			input="${OPTARG}"
			;;
		*)
			usage
			exit
			;;
	esac
done
shift $((OPTIND-1))

basedir=$(cd "$(dirname "$0")"; pwd)
pushd ${basedir}

if [ -z "${input}" ]; then
	input="${basedir}"
fi

rsync -havzP --rsync-path="sudo rsync" --stats ${input}/ panther:/usr/local/www/COVID-19/
