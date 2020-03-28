all: download csv placeholder generate

download:
	mkdir -p build
	wget -q -O build/Updates_NC.csv 'https://raw.githubusercontent.com/839Studio/Novel-Coronavirus-Updates/master/Updates_NC.csv'

csv:
	Rscript csv.R build/Updates_NC.csv build/Updates_NC-normalized.csv

generate:
	./generate.sh -i build/Updates_NC-normalized.csv -o build

html:
	./html.sh -i build/Updates_NC-normalized.csv -o build -f index.html
	./html.sh -i build/Updates_NC-normalized.csv -o build -y "新增确诊" -f confirmed.html
	./html.sh -i build/Updates_NC-normalized.csv -o build -y "新增出院" -f cured.html
	./html.sh -i build/Updates_NC-normalized.csv -o build -y "新增死亡" -f dead.html

placeholder:
	mkdir -p 'build/images'
	# White GIF.gif
	# http://proger.i-forge.net/Компьютер/[20121112]%20The%20smallest%20transparent%20pixel.html
	echo 'R0lGODlhAQABAIAAAP///wAAACwAAAAAAQABAAACAkQBADs=' | base64 -d > 'build/images/White GIF.gif'

images:
	./images.sh -i build/Updates_NC-normalized.csv -o build

clean:
	rm -rf build

upload:
	./upload.sh -i build
