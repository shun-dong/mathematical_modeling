import pandas as pd
import numpy as np

# 读取节点
df_nodes = pd.read_excel('附件2.xlsx')  # 列: 编号, x, y, z
df_nodes = df_nodes.reset_index(drop=True)
node_id_list = df_nodes['对应主索节点编号'].tolist()
node_index = {name: i for i, name in enumerate(node_id_list)}
coords0 = np.array(df_nodes[['基准态时上端点X坐标（米）', '基准态时上端点Y坐标（米）', '基准态时上端点Z坐标（米）']].values)  # n_nodes * 3
n_nodes = len(df_nodes)

# 读取面板（三点编号）
df_panels = pd.read_excel('附件3.xlsx')  # 列: 主索节点1, 主索节点2, 主索节点3
panel_triples = df_panels.values.tolist()

# FAST抛物面参数化
R = 300.0
f = 0.466 * R

# 天体方向
alpha_deg, beta_deg = 36.795, 78.169
alpha, beta = np.deg2rad(alpha_deg), np.deg2rad(beta_deg)
n_s = np.array([np.cos(beta)*np.cos(alpha), np.cos(beta)*np.sin(alpha), np.sin(beta)])
focus = -(R - f) * n_s  # 焦点

def mask(coord):
    """判断点是否在对称轴附近300米口径内"""
    axial = np.dot(coord, n_s)
    ortho = coord - axial * n_s
    return np.linalg.norm(ortho) <= 150.0  # 150米半径

masked_coords0 = []
mask_index={} # {new_id:old_id}
masked_n = -1
for i in range(n_nodes):
    if mask(coords0[i]):
        masked_n+=1
        masked_coords0 +=[coords0[i]]
        mask_index |= {masked_n:i} # 字典相加
masked_n += 1
print(masked_n)

# 实际上用离对称轴最近的节点估计vertex
vertex_id = np.argmin(np.einsum("ij,j->i", masked_coords0, n_s))
vertex = masked_coords0[vertex_id]

# 构造所有唯一边邻接（集合去重，避免重复约束）
edge_set = set()
for triple in panel_triples:
    for i in range(3):
        if mask(coords0[node_index[triple[i]]]): # 只要有一个点在区域类那么整条边都要考虑
            s, t = triple[i], triple[(i+1)%3]
            idx1, idx2 = node_index[s], node_index[t]
            # 排序避免重复边反向
            edge_set.add(tuple(sorted((idx1, idx2))))
            if not mask(coord:=coords0[node_index[triple[(i+1)%3]]]):
                mask_index |= {masked_n:node_index[triple[(i+1)%3]]}
                masked_coords0 += [coord]
                masked_n +=1
print(masked_n, len(masked_coords0))
edge_list = list(edge_set)
_mask_index = {v: k for k, v in mask_index.items()}
for i in range(len(edge_list)):
    j, k =edge_list[i]
    edge_list[i]=(_mask_index[j], _mask_index[k])

    


def get_adjusted_points(deltas):
    '''
    deltas: [n_nodes] 各节点的径向调节量
    return: 调节后各节点三维坐标(数组 n_nodes * 3)
    '''
    # 所有原点指向的单位向量 (从球心到节点)
    r0_norm = np.linalg.norm(masked_coords0, axis=1, keepdims=True)
    norm_dir = masked_coords0 / r0_norm
    coords_new = masked_coords0 + norm_dir * deltas[:,None]
    return coords_new

def point2paraboloid_dist(pt, n_s, vertex, focus):
    """点pt 到指定抛物面的轴向距离"""
    # 抛物面参数：vertex(顶点), n_s(对称轴), f (焦距)
    vec = pt - vertex
    axial = np.dot(vec, n_s)
    ortho = vec - axial * n_s
    parab_surface_axial = np.dot(ortho, ortho) / (4*np.linalg.norm(focus - vertex))
    signed_dist = axial - parab_surface_axial
    return signed_dist  # >0: 外侧, <0: 内侧


def target_obj(deltas):
    coords_new = get_adjusted_points(deltas)
    total = 0.0
    vertex = coords_new[vertex_id]
    for coord in coords_new:
        # if mask(coord):
            d = point2paraboloid_dist(coord, n_s, vertex, focus)
            total += d**2
    return total #距离平方和

# 预计算原始距离
a = [j for i,j in edge_list]
print(max(a))
d_orig = np.array([np.linalg.norm(masked_coords0[i]-masked_coords0[j]) for i,j in edge_list])
threshs = [0.1, 0.01, 0.005, 0.0007]  # 0.07%

def constraint_distances(deltas):
    coords_new = get_adjusted_points(deltas)
    vals = []
    for (k, (i, j)) in enumerate(edge_list):
        dist_new = np.linalg.norm(coords_new[i]-coords_new[j])
        rel = abs(dist_new - d_orig[k]) / d_orig[k]
        vals.append(thresh - rel)  # 保证 rel <= thresh，即 thresh-rel>=0
    return np.array(vals)


if __name__ == "__main__":
    from scipy.optimize import minimize, Bounds, NonlinearConstraint

    # 初值：0，即基准状态
    x0 = np.zeros(masked_n)
    bnds = [(-0.6, 0.6)]*masked_n  # 各节点

    # for thresh in threshs:
    #     # 以目标函数最小化，非线性约束
    #     cons = NonlinearConstraint(constraint_distances, 0, np.inf)  # 约束>=0
    #     res = minimize(target_obj, x0, method='SLSQP', bounds=bnds, constraints=[cons],options={'ftol':1e-9,'disp':True,'maxiter':100})
    #     x0 = res.x
    #     print(f"thresh:{thresh}, 最大伸缩量: {np.max(np.abs(x0))}")
    
    thresh = 0.0007  # 最终使用的阈值
    # 以目标函数最小化，非线性约束
    cons = NonlinearConstraint(constraint_distances, 0, np.inf)  # 约束>=0
    res = minimize(target_obj, x0, method='SLSQP', bounds=bnds, constraints=[cons],options={'ftol':1e-9,'disp':True,'maxiter':100})
    x0 = res.x
    print(f"thresh:{thresh}, 最大伸缩量: {np.max(np.abs(x0))}")

    # 输出调整后的节点坐标
    adjusted_coords = get_adjusted_points(x0)
    adjusted_df = pd.DataFrame(adjusted_coords, columns=['X坐标（米）', 'Y坐标（米）', 'Z坐标（米）'])
    adjusted_df.to_excel('adjusted_nodes.xlsx', index=False)

    # 输出 result.xlsx (节点编号与伸缩量，3位小数)
    # coords_new = coords0[:]
    # for i in range(masked_n):
    #     coords_new[mask_index[i]]=adjusted_coords[i]
    delta_all=np.zeros(n_nodes)
    for i in range(masked_n):
        delta_all[mask_index[i]]=x0[i]
    out_df = pd.DataFrame({'对应主索节点编号': node_id_list, '伸缩量（米）': np.round(delta_all,3)})
    out_df.to_excel('result.xlsx', index=False)  # 符合附件4格式

    # 顶点坐标保存
    with open("paraboloid_vertex.txt", "w") as f:
        f.write('理想抛物面顶点坐标: {:.3f}, {:.3f}, {:.3f}\n'.format(*vertex))
