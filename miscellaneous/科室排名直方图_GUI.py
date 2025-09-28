# 科室排名直方图生成工具（图形界面版）
# 此工具提供友好的图形界面，用于读取Excel文件中的科室排名数据，提取前10名并生成直方图

import pandas as pd
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import os

# 设置中文字体支持
plt.rcParams["font.family"] = ["SimHei", "WenQuanYi Micro Hei", "Heiti TC"]
plt.rcParams["axes.unicode_minus"] = False  # 解决负号显示问题

class DepartmentRankPlotter:
    def __init__(self, root):
        self.root = root
        self.root.title("科室排名直方图生成工具")
        self.root.geometry("800x600")
        
        # 设置主题
        self.style = ttk.Style()
        self.style.configure("TLabel", font=("SimHei", 10))
        self.style.configure("TButton", font=("SimHei", 10))
        self.style.configure("TEntry", font=("SimHei", 10))
        
        # 文件路径变量
        self.file_path = tk.StringVar()
        # 图表标题变量
        self.chart_title = tk.StringVar(value="科室排名直方图")
        # 科室列和数值列变量
        self.dept_col = tk.StringVar(value="科室")
        self.value_col = tk.StringVar(value="数值")
        # 数据变量
        self.data = None
        self.top_10_data = None
        
        # 创建界面
        self.create_widgets()
    
    def create_widgets(self):
        # 创建顶部框架用于文件选择和设置
        top_frame = ttk.Frame(self.root, padding="10")
        top_frame.pack(fill=tk.X)
        
        # 文件选择
        ttk.Label(top_frame, text="Excel文件: ").grid(row=0, column=0, sticky=tk.W, pady=5)
        ttk.Entry(top_frame, textvariable=self.file_path, width=50).grid(row=0, column=1, pady=5)
        ttk.Button(top_frame, text="浏览...", command=self.browse_file).grid(row=0, column=2, padx=5, pady=5)
        
        # 科室列名
        ttk.Label(top_frame, text="科室列名: ").grid(row=1, column=0, sticky=tk.W, pady=5)
        ttk.Entry(top_frame, textvariable=self.dept_col, width=20).grid(row=1, column=1, sticky=tk.W, pady=5)
        
        # 数值列名
        ttk.Label(top_frame, text="数值列名: ").grid(row=2, column=0, sticky=tk.W, pady=5)
        ttk.Entry(top_frame, textvariable=self.value_col, width=20).grid(row=2, column=1, sticky=tk.W, pady=5)
        
        # 图表标题
        ttk.Label(top_frame, text="图表标题: ").grid(row=3, column=0, sticky=tk.W, pady=5)
        ttk.Entry(top_frame, textvariable=self.chart_title, width=50).grid(row=3, column=1, columnspan=2, sticky=tk.W, pady=5)
        
        # 操作按钮
        btn_frame = ttk.Frame(self.root, padding="10")
        btn_frame.pack(fill=tk.X)
        
        ttk.Button(btn_frame, text="读取数据", command=self.load_data).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="显示前10名", command=self.show_top_10).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="生成直方图", command=self.generate_plot).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="保存图表", command=self.save_plot).pack(side=tk.LEFT, padx=5)
        
        # 创建数据预览区域
        data_frame = ttk.LabelFrame(self.root, text="数据预览", padding="10")
        data_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        # 创建表格
        columns = ("dept", "value")
        self.tree = ttk.Treeview(data_frame, columns=columns, show="headings", height=5)
        self.tree.heading("dept", text="科室")
        self.tree.heading("value", text="数值")
        self.tree.column("dept", width=300)
        self.tree.column("value", width=100, anchor=tk.CENTER)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # 添加滚动条
        scrollbar = ttk.Scrollbar(data_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # 创建图表区域
        self.plot_frame = ttk.LabelFrame(self.root, text="直方图", padding="10")
        self.plot_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        # 创建初始图表
        self.fig, self.ax = plt.subplots(figsize=(6, 4))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.plot_frame)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
    
    def browse_file(self):
        """浏览并选择Excel文件"""
        file_types = [("Excel文件", "*.xlsx;*.xls"), ("所有文件", "*.*")]
        file_path = filedialog.askopenfilename(filetypes=file_types)
        if file_path:
            self.file_path.set(file_path)
    
    def load_data(self):
        """加载Excel数据"""
        file_path = self.file_path.get()
        if not file_path or not os.path.exists(file_path):
            messagebox.showerror("错误", "请选择有效的Excel文件")
            return
        
        try:
            # 读取Excel文件
            self.data = pd.read_excel(file_path)
            
            # 显示数据列名供用户参考
            columns = self.data.columns.tolist()
            messagebox.showinfo("数据列名", f"Excel文件包含以下列：\n{', '.join(columns)}\n\n请确认科室列名和数值列名是否正确。")
            
            # 如果是第一次加载，自动设置列名
            if self.dept_col.get() == "科室" and columns:
                self.dept_col.set(columns[0])
            if self.value_col.get() == "数值" and len(columns) > 1:
                self.value_col.set(columns[1])
                
            # 预览数据前5行
            self.preview_data(self.data.head())
            
        except Exception as e:
            messagebox.showerror("错误", f"读取文件时出错：{str(e)}")
    
    def show_top_10(self):
        """显示前10名科室"""
        if self.data is None:
            messagebox.showinfo("提示", "请先读取数据")
            return
        
        try:
            dept_col = self.dept_col.get()
            value_col = self.value_col.get()
            
            # 检查列名是否存在
            if dept_col not in self.data.columns or value_col not in self.data.columns:
                messagebox.showerror("错误", "指定的列名不存在于数据中")
                return
            
            # 确保数值列是数值类型
            self.data[value_col] = pd.to_numeric(self.data[value_col], errors='coerce')
            
            # 去除NaN值并排序取前10名
            self.top_10_data = self.data.dropna(subset=[value_col])
            self.top_10_data = self.top_10_data.sort_values(by=value_col, ascending=False).head(10)
            
            # 预览前10名数据
            self.preview_data(self.top_10_data)
            
            messagebox.showinfo("成功", f"已提取前10名科室数据\n共{len(self.top_10_data)}条记录")
            
        except Exception as e:
            messagebox.showerror("错误", f"处理数据时出错：{str(e)}")
    
    def generate_plot(self):
        """生成直方图"""
        if self.top_10_data is None:
            messagebox.showinfo("提示", "请先显示前10名科室数据")
            return
        
        try:
            dept_col = self.dept_col.get()
            value_col = self.value_col.get()
            title = self.chart_title.get()
            
            # 清空当前图表
            self.ax.clear()
            
            # 创建直方图
            bars = self.ax.bar(self.top_10_data[dept_col], self.top_10_data[value_col], color='skyblue')
            
            # 添加数值标签
            for bar in bars:
                height = bar.get_height()
                self.ax.annotate(f'{height:.2f}',
                                xy=(bar.get_x() + bar.get_width() / 2, height),
                                xytext=(0, 3),  # 3 points vertical offset
                                textcoords="offset points",
                                ha='center', va='bottom')
            
            # 设置图表属性
            self.ax.set_title(title, fontsize=14)
            self.ax.set_xlabel(dept_col, fontsize=12)
            self.ax.set_ylabel(value_col, fontsize=12)
            
            # 旋转x轴标签避免重叠
            plt.xticks(rotation=45, ha='right')
            
            # 调整布局
            plt.tight_layout()
            
            # 更新画布
            self.canvas.draw()
            
        except Exception as e:
            messagebox.showerror("错误", f"生成图表时出错：{str(e)}")
    
    def save_plot(self):
        """保存图表"""
        if self.top_10_data is None:
            messagebox.showinfo("提示", "请先生成图表")
            return
        
        try:
            # 询问保存路径
            file_types = [("PNG图片", "*.png"), ("JPEG图片", "*.jpg"), ("PDF文件", "*.pdf")]
            save_path = filedialog.asksaveasfilename(defaultextension=".png", filetypes=file_types)
            
            if save_path:
                # 保存图表
                self.fig.savefig(save_path, dpi=300, bbox_inches='tight')
                messagebox.showinfo("成功", f"图表已保存至：{save_path}")
                
        except Exception as e:
            messagebox.showerror("错误", f"保存图表时出错：{str(e)}")
    
    def preview_data(self, data):
        """在表格中预览数据"""
        # 清空现有数据
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        # 插入新数据
        dept_col = self.dept_col.get()
        value_col = self.value_col.get()
        
        if dept_col in data.columns and value_col in data.columns:
            for _, row in data.iterrows():
                dept = str(row[dept_col]) if pd.notna(row[dept_col]) else ""
                value = f"{row[value_col]:.2f}" if pd.notna(row[value_col]) else ""
                self.tree.insert("", tk.END, values=(dept, value))

if __name__ == "__main__":
    root = tk.Tk()
    app = DepartmentRankPlotter(root)
    root.mainloop()