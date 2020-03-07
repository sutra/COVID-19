library(extrafont)
library(ggplot2)

loadfonts()
#fonts()

args = commandArgs(trailingOnly=TRUE)
input <- args[1]
output <- args[2]
y <- args[3]
color <- args[4]
area <- args[5]

area

data <- read.csv(file = input, sep = ",", header = TRUE)

if (!is.na(area)) {
	data <- data[which(data$省份 == area), ]
	title = area
} else {
	title = "全球"
}

na.zero.data.frame <- function(object, ...) {
	n <- length(object)
	r <- nrow(object)

	seq_n <- seq_len(n)
	seq_r <- seq_len(r)

	for(j in seq_n) {
		x <- object[[j]]

		if(!is.atomic(x)) next

		x <- is.na(x)

		for (i in seq_r) {
			if (x[i]) {
				object[j, i] <- 0
			}
		}
	}

	object
}

df <- aggregate(formula(paste0(y, "~报道时间")), data = data, FUN = sum, na.action = na.zero.data.frame)

begin = as.Date("2020-01-11", "%Y-%m-%d")
end = Sys.Date()

plot <- ggplot(data = df, aes_string(x = 'as.Date(报道时间, "%m月%d日")', y = y)) +
	geom_line(color = color, size = 0.25) +
	geom_point(color = color, size = 0.6) +
	geom_text(
		aes_string(label = paste0("round(", y, ", 1)")),
		vjust = "left",
		hjust = "left",
		show.legend = FALSE,
		angle = 45,
		size = 2
	) +
	geom_smooth(method="loess", size = 0.5) +
	xlim(begin, end) +
	scale_y_continuous(breaks = function(x, n = 5) pretty(x, n)[pretty(x, n) %% 1 == 0] ) +
	ggtitle(title) +
	xlab("日期") +
	ylab(y) +
	theme(text=element_text(family = "Arial Unicode MS", size = 8))

name <- paste0(title, "-", y)

ggsave(plot = plot, filename = paste0(name, "-screen", ".png"), path = output, height = 4, width = 12, dpi = "screen")
ggsave(plot = plot, filename = paste0(name, "-print",  ".png"), path = output, height = 4, width = 12, dpi = "print")
ggsave(plot = plot, filename = paste0(name, "-retina", ".png"), path = output, height = 4, width = 12, dpi = "retina")
