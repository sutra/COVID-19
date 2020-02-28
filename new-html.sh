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

htmlFilePath="${output}/new.html"

now=$(date +%s)
lastUpdateDate=$( \
	cat "${csvFilePath}" \
	| awk -F ',' 'NR != 1 {print $1}' \
	| sort \
	| uniq \
	| awk \
		-F ',' \
		'
		BEGIN {
			cmd = "date -j -f \"%m月%d日\" \"1月1日\" \"+%m月%d日\"";
			cmd | getline lastReportDate;
			close(cmd);
		}
		{
			cmd="date -j -f \"%m月%d日\" \""$1"\" \"+%m月%d日\"";
			cmd | getline reportDate;
			close(cmd);
			if (reportDate > lastReportDate) {
				lastReportDate = reportDate;
			}
		}
		END {
			print lastReportDate;
		}
		' \
)

cat > "${htmlFilePath}" <<- EOM
<!doctype html>
<html>
<head>
<title>2019冠狀病毒病疫情按地区每日新增确诊人数</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="2019冠狀病毒病疫情按地区每日新增确诊人数">
<style type="text/css">
img:not([src]) {
	visibility: hidden;
}

/* Fixes Firefox anomaly during image load */
@-moz-document url-prefix() {
	img:-moz-loading {
		visibility: hidden;
	}
}

/* Inset, by Dan Eden */

hr.style-six {
	border: 0;
	height: 0;
	border-top: 1px solid rgba(0, 0, 0, 0.1);
	border-bottom: 1px solid rgba(255, 255, 255, 0.3);
}

* {
	margin: 0;
	padding: 0;
}
header ul {
	text-align: right;
	font-size: xx-small;
	padding: 0 1em;
	list-style-type: none;
}
nav {
	padding: 1em;
}
menuitem {
	padding: 0.3em;
}
h1 {
	text-align: center;
}
h2 a:before {
	content: "#";
}
img {
	width: 100%;
}
footer {
	text-align: right;
	font-size: xx-small;
	padding: 2em 1em;
}
footer ul {
	list-style-type: none;
}
a {
	color: #818181;
	text-decoration: none;
}
a:hover {
	color: #000;
}
p.top {
	text-align: right;
	padding: 0.4em 1em;
	font-size: small;
}
p.top a:before {
	content: "^";
}
</style>
</head>
<body>
<header>
<a name="top"></a>
<ul>
	<li>最后更新：${lastUpdateDate}</li>
</ul>
<h1>2019冠狀病毒病疫情按地区每日新增确诊人数</h1>
</header>

<nav>
<menu>
EOM

total=$(cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 {
			sum += $4
		}
		END {
			print sum
		}
		' \
)

echo "<menuitem><a href=\"#all\">全球(${total})</a></menuitem>" >> "${htmlFilePath}"
cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 && $2 != "" {
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
		'
		{
			print "<menuitem><a href=\"#"$2"\">"$2"("$1")</a></menuitem>"
		}
		' \
	>> "${htmlFilePath}"

cat >> "${htmlFilePath}" <<- EOM
</menu>
</nav>
<hr class="style-six" />
<a name="all"></a>
<h2><a href="#all">全球(${total})</a></h2>
<p><img alt="全球" class="lazy" src="images/new-screen.png?t=${now}" data-src="images/new-print.png?t=${now}" data-srcset="images/new-print.png?t=${now} 1x, images/new-retina.png?t=${now} 2x" /></p>
<p class="top"><a href="#top">top</a></p>
<hr class="style-six" data-content="全球" />
EOM

cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 && $2 != "" {
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
		-v "now=${now}" \
		'
		{
			print "<a name=\""$2"\"></a><h2><a href=\"#"$2"\">"$2"("$1")""</a></h2><p><img alt=\""$2"\" class=\"lazy\" src=\"images/new-"$2"-screen.png?t="now"\" data-src=\"images/new-"$2"-print.png?t="now"\" data-srcset=\"images/new-"$2"-print.png?t="now" 1x, images/new-"$2"-retina.png?t="now" 2x\" /></p><p class=\"top\"><a href=\"#top\">top</a></p><hr class=\"style-six\" />"
		}
		' \
	>> "${htmlFilePath}"

cat >> "${htmlFilePath}" <<- EOM
<footer>
<ul>
	<li>最后更新：${lastUpdateDate}</li>
	<li><a href="https://mp.weixin.qq.com/s/sTAn2ZrJTQyvLEqXMyYeDg">疫情数据由澎湃新闻美数课整理提供</a></li>
	<li><a href="https://github.com/sutra/COVID-19">© 2020 Sutra Zhou</a></li>
</ul>
</footer>
<script src="https://cdn.jsdelivr.net/npm/vanilla-lazyload@12.4.0/dist/lazyload.min.js"></script>
<script type="text/javascript">
<!--
var lazyLoadInstance = new LazyLoad({
	elements_selector: ".lazy"
});
//-->
</script>
</body>
</html>
EOM
