### 新建"R-fun-自己名字拼音.R"的代码，完成以下三大部分内容 ###

## 1. 关于函数的学习
# 1.1 用data.frame()生存一个名字为a的数据框，其中a1列是（2，4，6），a2列是（3，5，8），a3列是（4，1，9），并用head（a）展示出来
a<-data.frame(a1=c(2,4,6),a2=c(3,5,8),a3=c(4,1,9))

head(a)

# 1.2 用'?pmin'学习pmin函数的功能,比较‘pmin’ 和 'min' 的区别，用pmin()展示以下效果

pmin(a$a1,a$a2,a$a3)


# 1.3 自定义名为pmin_apply的一个函数，函数中只使用apply和min，实现pmin的功能
pmin_apply<-function(x){apply(x,1,min)}

pmin_apply(a)

# 1.4自定义名为pmin_for的一个函数，函数中使用for和min，还可使用其他函数（如nrow，length，numeric等），实现pmin的功能
pmin_for<-function(x){
  y=numeric(nrow(x))
 for(i in 1:nrow(x)){y[i]=min(x[i,])}
  y}

pmin_for(a)

# 1.5 以上函数运行成功以后，安装bench包，通过以下指令比较一下时间
bench::mark(base=pmin(a$a1,a$a2,a$a3),
            pmin_apply=pmin_apply(a),
            pmin_for=pmin_for(a)
            )


## 2. 关于merge的理解
# 2.1 用data.frame()生存一个名字为b1的数据框，其中name列是("文","颜","唐","黄")，对应的score列是（95，96，97，98）,同样方法生存b2的数据框，两者展示如下
b1<-data.frame(name_b1=c("文","颜","唐","黄"),score=95:98)
b2<-data.frame(name_b2=c("文","颜"),github=c("uuu1016","yanyutong111"))

head(b1)
head(b2)

# 2.2 用'?merge'学习merge函数的功能,用merge()展示以下效果

merge(b1,b2,by=1)

# 2.3 接着加载dplyr包，用%>%结合merge实现同样的效果

library(dplyr)
b1 %>% merge(b2,by=1)

# 2.4 自定义'%merge%'函数，实现以下效果（注意输出的行名！）
'%merge%'<-function(x,y){
  z=merge(x,y,by=1)
  row.names(z)<-z[,1]
  z[,-1]
}

b1 %merge% b2


## 3. 关于代码的共享操作

# 3.1 以上代码运行无误以后，把"R-fun-自己名字.R"的代码，通过github desktop同步到自己github账户下的code文件夹；

# 3.2 把"R-fun-自己名字.R"的代码，通过AI（推荐使用VS code + github coploit的组合，当然使用Deepseek等工具也可以，当然自己手动修改也行），
# 转化成一个新的R Markdown格式的文件，运行成功后保存为一个新的html格式文件，连个文件也同样同步到github的code文件夹；

# 3.3 以上R Markdown格式的文件运行后，选择在Rpub公布（需要新建一个账号），保存链接地址，粘贴在github名下README文件，保存后同步到github。




