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

${basedir}/images.sh \
	-i "${input}" \
	-o "${output}"

status=$?
if [ ${status} -ne 0 ]; then
	exit ${status}
fi

${basedir}/html.sh \
	-i "${input}" \
	-o "${output}" \
	-f index.html

${basedir}/html.sh \
	-i "${input}" \
	-o "${output}" \
	-y "新增确诊" \
	-f confirmed.html

${basedir}/html.sh \
	-i "${input}" \
	-o "${output}" \
	-y "新增出院" \
	-f cured.html

	${basedir}/html.sh \
	-i "${input}" \
	-o "${output}" \
	-y "新增死亡" \
	-f dead.html
