all: download csv generate

download:
	mkdir -p build
	wget -q -O build/Updates_NC.csv 'https://raw.githubusercontent.com/839Studio/Novel-Coronavirus-Updates/master/Updates_NC.csv'

csv:
	Rscript csv.R build/Updates_NC.csv build/Updates_NC-normalized.csv

generate:
	./generate.sh -i build/Updates_NC-normalized.csv -o build

html:
	./html.sh -i build/Updates_NC-normalized.csv -o build

images:
	./images.sh -i build/Updates_NC-normalized.csv -o build

clean:
	rm -rf build

upload:
	./upload.sh -i build
