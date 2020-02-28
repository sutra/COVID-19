library(extrafont)
library(ggplot2)

loadfonts()
#fonts()

args = commandArgs(trailingOnly=TRUE)
input <- args[1]
output <- args[2]
area <- args[3]

area

data <- read.csv(file = input, sep = ",", header = TRUE)

if (!is.na(area)) {
  data <- data[which(data$省份 == area), ]
  title = area
} else {
  title = "全球"
}

df <- aggregate(新增确诊~报道时间, data = data, FUN = sum)

begin = as.Date("2020-01-11", "%Y-%m-%d")
end = Sys.Date()

plot <- ggplot(data = df, aes(x = as.Date(报道时间, "%m月%d日"), y = 新增确诊)) +
  geom_line(color = "red", size = 0.25) +
  geom_point(color = "red", size = 0.6) +
  geom_text(
    aes(label = round(新增确诊, 1)),
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
  ylab("新增确诊") +
  theme(text=element_text(family = "Arial Unicode MS", size = 12))

name <- "new"
if (!is.na(area)) {
  name <- paste("new-", area, sep = "")
}

ggsave(plot = plot, filename = paste(name, "-screen", ".png", sep = ""), path = output, height = 4, width = 8, dpi = "screen")
ggsave(plot = plot, filename = paste(name, "-print",  ".png", sep = ""), path = output, height = 4, width = 8, dpi = "print")
ggsave(plot = plot, filename = paste(name, "-retina", ".png", sep = ""), path = output, height = 4, width = 8, dpi = "retina")
