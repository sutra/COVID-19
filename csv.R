args = commandArgs(trailingOnly=TRUE)
input <- args[1]
output <- args[2]

df <- read.csv(file = input, sep = ",", header = TRUE)

write.csv(df[c("报道时间", "省份", "城市", "新增确诊", "新增出院", "新增死亡")], output, row.names = FALSE, quote = FALSE)
