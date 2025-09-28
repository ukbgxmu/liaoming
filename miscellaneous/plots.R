# 桑甚图和冲积图示例
# 加载必要的包
library(networkD3)  # 用于桑甚图
library(ggalluvial)  # 用于冲积图
library(alluvial)
library(ggplot2)
library(dplyr)

# 设置中文显示
# 如果使用RStudio，确保图形设备支持中文
if (Sys.info()["sysname"] == "Windows") {
  windowsFonts("SimHei" = windowsFont("SimHei"))
  theme_set(theme_grey(base_family = "SimHei"))
} else {
  # Linux或Mac系统可能需要其他字体设置
  theme_set(theme_grey())
}

# ==============================================================================
# 第一部分：桑甚图 (Sankey Diagram)
# ==============================================================================

# 创建桑甚图数据
# 1. 定义节点
nodes <- data.frame(
  name = c("开始", "A类患者", "B类患者", "C类患者", 
           "治疗方案1", "治疗方案2", "治疗方案3", 
           "治愈", "好转", "未愈")
)

# 2. 定义连接关系和值
links <- data.frame(
  source = c(0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 6),  # 节点索引从0开始
  target = c(1, 2, 3, 4, 5, 5, 6, 4, 6, 7, 8, 9),
  value = c(100, 150, 80, 60, 40, 90, 60, 50, 30, 70, 110, 40)
)

# 生成桑甚图
sankey_plot <- sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = "source",
  Target = "target",
  Value = "value",
  NodeID = "name",
  fontSize = 12,
  nodeWidth = 30,
  nodePadding = 10,
  margin = list(top = 20, right = 30, left = 20, bottom = 20),
  sinksRight = FALSE  # 让所有节点按照我们定义的顺序排列
)

# 显示桑甚图
print(sankey_plot)

# 如果需要保存桑甚图为HTML文件
# saveNetwork(sankey_plot, "桑甚图示例.html", selfcontained = TRUE)

# ==============================================================================
# 第二部分：冲积图 (Alluvial Diagram)
# ==============================================================================

# 加载必要的包
library(alluvial)
library(dplyr)

# 创建示例数据
treatment_data <- data.frame(
  患者ID = 1:200,
  初始诊断 = sample(c("感冒", "发烧", "咳嗽", "喉咙痛"), 200, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1)),
  治疗方案 = sample(c("药物A", "药物B", "药物C", "休息"), 200, replace = TRUE, prob = c(0.3, 0.25, 0.25, 0.2)),
  治疗结果 = sample(c("治愈", "好转", "未愈"), 200, replace = TRUE, prob = c(0.6, 0.3, 0.1))
)

# 统计各组合的频数
treatment_counts <- treatment_data %>%
  group_by(初始诊断, 治疗方案, 治疗结果) %>%
  summarise(频数 = n(), .groups = "drop")

# 使用alluvial包创建冲积图
alluvial(treatment_counts[,1:3], freq = treatment_counts$频数, 
         col = rainbow(length(unique(treatment_counts$初始诊断)))[as.integer(treatment_counts$初始诊断)],
         alpha = 0.8, cex = 0.7,
         main = "患者治疗路径冲积图")


# ==============================================================================
# 第三部分：交互式桑甚图 (使用sankeyD3包，如需安装请取消下面注释)
# ==============================================================================

# 安装sankeyD3包(如果需要)
# install.packages("sankeyD3")
# library(sankeyD3)

# # 使用sankeyD3创建交互式桑甚图
# sankey_d3_plot <- sankeyD3(
#   Links = links,
#   Nodes = nodes,
#   Source = "source",
#   Target = "target",
#   Value = "value",
#   NodeID = "name",
#   width = 800,
#   height = 400,
#   fontSize = 12,
#   nodePadding = 10,
#   units = "人数"
# )
# 
# # 显示交互式桑甚图
# sankey_d3_plot
# 是的，`circlize` 包是专门用于绘制圈图的。以下是添加该包加载的示例
# 可在已有包加载部分添加
library(circlize)  # 用于绘制圈图
# 第三部分：圈图示例
# 创建简单的圈图数据
# 这里使用矩阵表示不同类别之间的关系
circos_data <- matrix(c(10, 20, 30, 40, 50, 60), nrow = 3, 
                      dimnames = list(c("类别A", "类别B", "类别C"), 
                                      c("类别X", "类别Y")))

# 初始化circlize
circos.clear()
circos.par(start.degree = 90)  # 设置起始角度

# 将所有行名和列名合并作为因子
all_categories <- c(rownames(circos_data), colnames(circos_data))
circos.initialize(factors = all_categories, xlim = cbind(rep(0, length(all_categories)), 1))

# 绘制所有类别区域
circos.trackPlotRegion(factors = all_categories, ylim = c(0, 1), 
                       panel.fun = function(x, y) {
                         sector.name = get.cell.meta.data("sector.index")
                         circos.text(0.5, 0.5, sector.name, cex = 0.8, facing = "bending.inside")
                       })

# 添加连接
# 绘制行名到列名的连接
for(i in 1:nrow(circos_data)) {
  for(j in 1:ncol(circos_data)) {
    circos.link(rownames(circos_data)[i], c(0, 1), 
                colnames(circos_data)[j], c(0, 1), 
                col = rgb(i/3, j/2, 0.5, alpha = 0.5))
  }
}

# 添加内部连接示例：在类别A、B、C之间添加连接
for(i in 1:(length(rownames(circos_data))-1)) {
  for(j in (i+1):length(rownames(circos_data))) {
    circos.link(rownames(circos_data)[i], c(0, 1), 
                rownames(circos_data)[j], c(0, 1), 
                col = rgb(i/3, j/3, 0.8, alpha = 0.3))
  }
}

# 添加类别X和Y之间的连接
circos.link(colnames(circos_data)[1], c(0, 1), 
            colnames(circos_data)[2], c(0, 1), 
            col = rgb(0.2, 0.8, 0.4, alpha = 0.3))

# 结束circlize
circos.clear()

