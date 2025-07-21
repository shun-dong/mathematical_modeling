import numpy as np
import pandas as pd

# 读取节点数据
df = pd.read_excel("附件1.xlsx") # 假设你的数据保存为excel，调整成实际路径

R = 300 # 球面半径（米）
f = 0.466 * R # 抛物面焦距
z0 = -f       # 顶点z坐标

def solve_lambda(x, y, z):
    # 沿球心方向缩放lambda后，落在抛物面
    # 新点为 (lx, ly, lz)
    # 需满足: lz = (lx^2+ly^2)/(4f) + z0
    # lz = l*z0 + offset, lx = l*x; ly = l*y
    # 所以: lz = (l^2*x^2 + l^2*y^2)/(4f) + z0
    # lz = l*z
    # 方程: l*z = (l^2*(x^2 + y^2))/(4f) + z0
    
    A = (x**2 + y**2)/(4*f)
    B = z
    C = -z0
    
    # l*B - (l^2)*A = -C
    # l^2*A - l*B + C = 0
    # 求l>0根
    a = A
    b = -B
    c = C
    roots = np.roots([a, b, c])
    l_real = roots[np.isreal(roots) & (roots > 0)].real
    if len(l_real) == 0:
        return 1 # 默认取1，说明该点不需移动
    return l_real[0]

results = []
for idx, row in df.iterrows():
    name = row['节点编号']
    x0, y0, z0_ = row['X坐标（米）'], row['Y坐标（米）'], row['Z坐标（米）']
    l = solve_lambda(x0, y0, z0_)
    x1, y1, z1 = l * x0, l * y0, l * z0_
    move = np.sqrt(x1**2 + y1**2 + z1**2) - np.sqrt(x0**2 + y0**2 + z0_**2)
    results.append([name, x0, y0, z0_, x1, y1, z1, move])

# 输出 DataFrame
df_out = pd.DataFrame(results, columns=['节点编号',
                                        '原X', '原Y', '原Z',
                                        '目标X', '目标Y', '目标Z',
                                        '径向移动量(米)'])
df_out.to_excel('面板调节优化结果.xlsx', index=False)

print(df_out.head(10))
