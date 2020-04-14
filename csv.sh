#!/bin/sh
Rscript csv.R build/Updates_NC.csv build/Updates_NC-normalized.csv
sed -i '' 's/?//' build/Updates_NC-normalized.csv
awk -F ',' 'NR == 1 || $1~/^[0-9]+月[0-9]+日$/{print $0}' build/Updates_NC-normalized.csv > build/Updates_NC-normalized.csv.clean \
	&& mv build/Updates_NC-normalized.csv.clean build/Updates_NC-normalized.csv
