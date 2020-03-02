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

csvFilePath="${input}"

if [ ! -f "${csvFilePath}" ]; then
	echo "${csvFilePath} does not exist."
	exit 1
fi

if [ -z "${output}" ]; then
	output=$(pwd)
else
	mkdir -p "${output}"
fi

imageOutput="${output}/images"
mkdir -p "${imageOutput}"

Rscript "${basedir}/image.R" "${input}" "${imageOutput}" "新增确诊" "red"
Rscript "${basedir}/image.R" "${input}" "${imageOutput}" "新增出院" "#28B7A3"
Rscript "${basedir}/image.R" "${input}" "${imageOutput}" "新增死亡" "#5D7092"
cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 {
			sum[$2] += $4
		}
		END {
			for (i in sum) {
				print sum[i] " " i
			}
		}
		' \
	| sort -nr \
	| awk \
		-v "basedir=${basedir}" \
		-v "input=${input}" \
		-v "imageOutput=${imageOutput}" \
		'
		$2 != "" {
			cmd="Rscript "basedir"/image.R \"" input "\" \"" imageOutput "\" \"新增确诊\" \"red\" \"" $2 "\""
			print cmd
			system(cmd)

			cmd="Rscript "basedir"/image.R \"" input "\" \"" imageOutput "\" \"新增出院\" \"#28B7A3\" \"" $2 "\""
			print cmd
			system(cmd)

			cmd="Rscript "basedir"/image.R \"" input "\" \"" imageOutput "\" \"新增死亡\" \"#5D7092\" \"" $2 "\""
			print cmd
			system(cmd)
		}
		'
