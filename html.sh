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

htmlFilePath="${output}/index.html"

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

hgroup {
	text-align: center;
	font-family: Verdana, sans-serif;
}

h1 {
	font-size: 1.93rem;
	margin-bottom: 0;
}

h2 {
	font-size: 1.16rem;
	margin-top: 0;
}

section h2 a:before {
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

.confirmed {
	color: red;
}
.cured {
	color: #59C697
}
.dead {
	color: #5D7092;
}
</style>
</head>
<body>
<header>
	<a name="top"></a>
	<hgroup>
		<h1>2019冠狀病毒病疫情</h1>
		<h2>按地区每日新增确诊/出院/死亡人数</h2>
	</hgroup>
	<ul>
		<li>最后更新：${lastUpdateDate}</li>
	</ul>
</header>

<nav>
<menu>
EOM

cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 {
			total_confirmed += $4
			total_cured += $5
			total_dead += $6
		}
		NR != 1 && $2 != "" {
			confirmed[$2] += $4
			cured[$2] += $5
			dead[$2] += $6
		}
		END {
			print total_confirmed " " total_cured " " total_dead " 全球"
			for (i in confirmed) {
				print confirmed[i] " " cured[i] " " dead[i] " " i
			}
		}
		' \
	| sort -nr \
	| awk \
		'
		{
			print "<menuitem><a href=\"#"$4"\">"$4"(<span class=\"confirmed\">"$1"</span>/<span class=\"cured\">"$2"</span>/<span class=\"dead\">"$3"</span>)</a></menuitem>"
		}
		' \
	>> "${htmlFilePath}"

cat >> "${htmlFilePath}" <<- EOM
</menu>
</nav>

<hr class="style-six" />

EOM

cat "${csvFilePath}" \
	| awk \
		-F ',' \
		'
		NR != 1 {
			total_confirmed += $4
			total_cured += $5
			total_dead += $6
		}
		NR != 1 && $2 != "" {
			confirmed[$2] += $4
			cured[$2] += $5
			dead[$2] += $6
		}
		END {
			print total_confirmed " " total_cured " " total_dead " 全球"
			for (i in confirmed) {
				print confirmed[i] " " cured[i] " " dead[i] " " i
			}
		}
		' \
	| sort -nr \
	| awk \
		-v "now=${now}" \
		'
		{
			print "<section>"
			print "<a name=\""$4"\"></a>"
			print "<h2><a href=\"#"$4"\">"$4"(<span class=\"confirmed\">"$1"</span>/<span class=\"cured\">"$2"</span>/<span class=\"dead\">"$3"</span>)</a></h2>"
			print "<p><img alt=\""$4"\" class=\"lazy\" src=\"images/新增确诊-"$4"-screen.png?t="now"\" data-src=\"images/新增确诊-"$4"-print.png?t="now"\" data-srcset=\"images/新增确诊-"$4"-print.png?t="now" 1x, images/新增确诊-"$4"-retina.png?t="now" 2x\" /></p>"
			print "<p><img alt=\""$4"\" class=\"lazy\" src=\"images/新增出院-"$4"-screen.png?t="now"\" data-src=\"images/新增出院-"$4"-print.png?t="now"\" data-srcset=\"images/新增出院-"$4"-print.png?t="now" 1x, images/新增出院-"$4"-retina.png?t="now" 2x\" /></p>"
			print "<p><img alt=\""$4"\" class=\"lazy\" src=\"images/新增死亡-"$4"-screen.png?t="now"\" data-src=\"images/新增死亡-"$4"-print.png?t="now"\" data-srcset=\"images/新增死亡-"$4"-print.png?t="now" 1x, images/新增死亡-"$4"-retina.png?t="now" 2x\" /></p>"
			print "<p class=\"top\"><a href=\"#top\">top</a></p>"
			print "<hr class=\"style-six\" />"
			print "</section>"
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
