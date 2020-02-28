#!/bin/sh
usage() {
cat << EOF
usage: $0 <-i input> [-o output]
	-i input
	-o output
EOF
}

while getopts ":i:o:" o; do
	case "${o}" in
		i)
			input="${OPTARG}"
			;;
		o)
			output="${OPTARG}"
			;;
		*)
			usage
			exit
			;;
	esac
done
shift $((OPTIND-1))

basedir=$(cd "$(dirname "$0")"; pwd)

if [ -z "${input}" ]; then
	input="${basedir}"
fi

if [ -z "${output}" ]; then
	output=$(pwd)
else
	mkdir -p "${output}"
fi

${basedir}/new-images.sh \
	-i "${input}" \
	-o "${output}"

status=$?
if [ ${status} -ne 0 ]; then
	exit ${status}
fi

${basedir}/new-html.sh \
	-i "${input}" \
	-o "${output}"
