import tkinter as tk
from tkinter import messagebox
from tkinter import ttk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# 创建主窗口
root = tk.Tk()
root.title("老旧街区搬迁决策软件")
root.geometry("800x600")

# 输入框区域：地块信息
tk.Label(root, text="地块ID").grid(row=0, column=0, padx=20, pady=10)
land_id_input = tk.Entry(root)
land_id_input.grid(row=0, column=1, padx=20, pady=10)

tk.Label(root, text="院落ID").grid(row=1, column=0, padx=20, pady=10)
courtyard_id_input = tk.Entry(root)
courtyard_id_input.grid(row=1, column=1, padx=20, pady=10)

tk.Label(root, text="地块面积 (m²)").grid(row=2, column=0, padx=20, pady=10)
land_area_input = tk.Entry(root)
land_area_input.grid(row=2, column=1, padx=20, pady=10)

tk.Label(root, text="地块朝向").grid(row=3, column=0, padx=20, pady=10)
orientation_input = tk.Entry(root)
orientation_input.grid(row=3, column=1, padx=20, pady=10)

tk.Label(root, text="是否有居民").grid(row=4, column=0, padx=20, pady=10)
has_residents_input = tk.Entry(root)
has_residents_input.grid(row=4, column=1, padx=20, pady=10)


# 按钮：生成选择方案
def generate_options():
    try:
        land_id = land_id_input.get()
        courtyard_id = courtyard_id_input.get()
        land_area = float(land_area_input.get())
        orientation = orientation_input.get()
        has_residents = has_residents_input.get().lower() == 'yes'

        # 模拟生成多个选择方案
        options_list.delete(0, tk.END)  # 清除之前的选项
        if has_residents:
            options_list.insert(tk.END, f"方案1: 地块ID: {land_id}，院落ID: {courtyard_id}，搬迁补偿：20000元")
            options_list.insert(tk.END, f"方案2: 地块ID: {land_id}，院落ID: {courtyard_id}，搬迁补偿：25000元")
        else:
            options_list.insert(tk.END, f"方案3: 地块ID: {land_id}，院落ID: {courtyard_id}，搬迁补偿：15000元")
            options_list.insert(tk.END, f"方案4: 地块ID: {land_id}，院落ID: {courtyard_id}，搬迁补偿：10000元")

        # 显示选项框
        options_list.grid(row=5, column=0, columnspan=2, padx=20, pady=10)

    except ValueError:
        messagebox.showerror("输入错误", "请输入有效的数值!")


# 选择方案并填写补偿金额
def submit_compensation():
    try:
        selected_option = options_list.curselection()
        if not selected_option:
            messagebox.showwarning("未选择", "请选择一个方案!")
            return
        selected_plan = options_list.get(selected_option)
        compensation_input_label.config(text=f"选中的方案: {selected_plan}")

        # 让用户填写补偿金额
        compensation_input.grid(row=7, column=0, padx=20, pady=10)
        compensation_input_button.grid(row=7, column=1, padx=20, pady=10)
    except Exception as e:
        messagebox.showerror("错误", f"发生错误: {str(e)}")


# 用户填写补偿金额并提交
def final_submit():
    try:
        compensation_value = float(compensation_input.get())
        messagebox.showinfo("提交成功", f"补偿金额为 {compensation_value} 元，提交成功！")
    except ValueError:
        messagebox.showerror("输入错误", "请输入有效的补偿金额!")


# 按钮区域：生成选择方案
generate_button = tk.Button(root, text="生成搬迁方案", command=generate_options)
generate_button.grid(row=6, column=0, columnspan=2, pady=20)

# 选择方案的列表框
options_list = tk.Listbox(root, height=5, width=60)

# 显示补偿金额输入框
compensation_input_label = tk.Label(root, text="请选择方案并输入补偿金额")
compensation_input_label.grid(row=8, column=0, columnspan=2)

compensation_input = tk.Entry(root)
compensation_input.grid(row=9, column=0, padx=20, pady=10)

compensation_input_button = tk.Button(root, text="提交补偿金额", command=final_submit)

# 提交选择方案按钮
submit_button = tk.Button(root, text="提交方案选择", command=submit_compensation)
submit_button.grid(row=9, column=1, padx=20, pady=10)

# 启动应用
root.mainloop()
