#!/bin/sh
usage() {
cat << EOF
usage: $0 <-i input> [-o output] [-f filename] [-y y]
	-i input
	-o output
	-f output filename
	-y the y axis value
EOF
}

while getopts ":i:o:f:y:" o; do
	case "${o}" in
		i)
			input="${OPTARG}"
			;;
		o)
			output="${OPTARG}"
			;;
		f)
			filename="${OPTARG}"
			;;
		y)
			y="${OPTARG}"
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

if [ -z "${filename}" ]; then
	filename="index.html"
fi

htmlFilePath="${output}/${filename}"

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
<title>2019冠状病毒病疫情 - 按地区每日新增确诊/出院/死亡人数</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="2019冠状病毒病疫情 - 按地区每日新增确诊/出院/死亡人数">
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

menuitem {
	padding: 0.3em;
	display: inline-block;
}

menuitem a {
	display: inline-block;
	width: 100%;
}

menuitem a:hover {
	text-decoration: none;
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

section h2 a::before {
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
p.top a::before {
	content: "^";
}

.confirmed {
	color: #FF5B5C;
}
.cured {
	color: #59C697
}
.dead {
	color: #5D7092;
}
.existing {
	color: #FF3535;
}

.explanation {
	font-size: x-small;
}
menuitem .explanation::before {
	content: " ";
}
section .explanation::before {
	content: " ";
}

menuitem .equation {
	display: none;
}
</style>
</head>
<body>
<header>
	<a name="top"></a>
	<hgroup>
		<h1>2019冠状病毒病疫情</h1>
		<h2>按地区每日<a href="index.html">新增</a><a href="confirmed.html">确诊</a>/<a href="cured.html">出院</a>/<a href="dead.html">死亡</a>人数</h2>
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
			print total_confirmed - total_cured - total_dead " " total_confirmed " " total_cured " " total_dead " 全球"
			for (i in confirmed) {
				print confirmed[i] - cured[i] - dead[i] " " confirmed[i] " " cured[i] " " dead[i] " " i
			}
		}
		' \
	| sort -nr \
	| awk \
		'
		{
			existing = $1
			confirmed = $2
			cured = $3
			dead = $4
			area = $5

			print "<menuitem>"
			print "<a href=\"#"area"\" title=\""confirmed"-"cured"-"dead"="existing"\">"area"<span class=\"explanation\"><span class=\"equation\"><span class=\"confirmed\">"confirmed"</span>-<span class=\"cured\">"cured"</span>-<span class=\"dead\">"dead"</span>=</span><span class=\"existing\">"existing"</span></span></a>"
			print" </menuitem>"
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
			print total_confirmed - total_cured - total_dead " " total_confirmed " " total_cured " " total_dead " 全球"
			for (i in confirmed) {
				print confirmed[i] - cured[i] - dead[i] " " confirmed[i] " " cured[i] " " dead[i] " " i
			}
		}
		' \
	| sort -nr \
	| awk \
		-v "lastUpdateDate=${lastUpdateDate}" \
		-v "y=${y}" \
		'
		{
			existing = $1
			confirmed = $2
			cured = $3
			dead = $4
			area = $5

			print "<section>"
			print "<a name=\""area"\"></a>"
			print "<h2>"
			print "<a href=\"#"area"\" title=\""confirmed"-"cured"-"dead"="existing"\">"area"<span class=\"explanation\"><span class=\"equation\"><span class=\"confirmed\">"confirmed"</span>-<span class=\"cured\">"cured"</span>-<span class=\"dead\">"dead"</span>=</span><span class=\"existing\">"existing"</span></span></a>"
			print "</h2>"
			if (y == "") {
				print "<p><img alt=\""area"-新增确诊\" class=\"lazy\" src=\"images/White GIF.gif\" data-src=\"images/"area"-新增确诊-print.png?t="lastUpdateDate"\" data-srcset=\"images/"area"-新增确诊-print.png?t="lastUpdateDate" 1x, images/"area"-新增确诊-retina.png?t="lastUpdateDate" 2x\" /></p>"
				print "<p><img alt=\""area"-新增出院\" class=\"lazy\" src=\"images/White GIF.gif\" data-src=\"images/"area"-新增出院-print.png?t="lastUpdateDate"\" data-srcset=\"images/"area"-新增出院-print.png?t="lastUpdateDate" 1x, images/"area"-新增出院-retina.png?t="lastUpdateDate" 2x\" /></p>"
				print "<p><img alt=\""area"-新增死亡\" class=\"lazy\" src=\"images/White GIF.gif\" data-src=\"images/"area"-新增死亡-print.png?t="lastUpdateDate"\" data-srcset=\"images/"area"-新增死亡-print.png?t="lastUpdateDate" 1x, images/"area"-新增死亡-retina.png?t="lastUpdateDate" 2x\" /></p>"
			} else {
				print "<p><img alt=\""area"-"y"\" class=\"lazy\" src=\"images/White GIF.gif\" data-src=\"images/"area"-"y"-print.png?t="lastUpdateDate"\" data-srcset=\"images/"area"-"y"-print.png?t="lastUpdateDate" 1x, images/"area"-"y"-retina.png?t="lastUpdateDate" 2x\" /></p>"
			}
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
