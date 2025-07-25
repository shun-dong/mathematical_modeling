import matplotlib.pyplot as plt
import numpy as np

# 定义数据，ResidentPlotID 和对应的 M 值
resident_ids = [3, 5, 7, 9, 14, 18, 29, 30, 31, 34, 38, 39, 40, 41, 49, 50,
                74, 75, 76, 77, 80, 81, 91, 92, 93, 106, 107, 110, 111,
                120, 121, 132, 138, 139, 140, 141, 142, 171, 172, 179,
                180, 181, 182, 191, 192, 193, 194, 195, 196, 197, 198,
                200, 203, 204, 206, 207, 210, 211, 215, 220, 224, 225,
                235, 238, 239, 240, 241, 242, 243, 244, 245, 266, 267,
                268, 296, 297, 317, 318, 319, 320, 321, 327, 349, 350,
                351, 352, 376, 380, 381, 384, 385, 390, 393, 401, 403,
                409, 424, 433, 451, 452, 453, 454, 455, 459, 461, 462,
                468, 469, 475, 477, 478]  # ResidentPlotID
#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
m_values = [20.13240947, 23.3415632, 22.4322482, 22.54113987, 29.520463,
            28.77274873, 20.8461638, 28.6119054, 19.59853613, 31.3231254,
            25.84197487, 29.43140767, 25.04179487, 19.58473547, 29.72305467,
            23.72789513, 25.03846987, 32.20547133, 24.98055653, 31.74494373,
            24.50928447, 24.50928447, 22.61830453, 27.20652767, 30.0862844,
            20.42748293, 31.025848, 20.40715187, 22.40124227, 25.88659893,
            25.89389893, 29.49633147, 31.74494373, 31.74591707, 29.48246767,
            29.48429267, 25.10781987, 29.19691367, 25.13020653, 29.62520067,
            29.61984733, 32.20839133, 32.20352467, 32.17773133, 25.10489987,
            25.00245653, 25.00245653, 25.11949987, 25.11584987, 25.10124987,
            32.20352467, 25.12282487, 17.64846747, 17.69372747, 25.1087932,
            25.10672487, 25.10684653, 32.18320633, 22.75777693, 25.13399687,
            25.13117987, 25.12533987, 22.68208487, 22.85971133, 25.02691153,
            24.30526187, 26.183942, 25.05306987, 25.05306987, 25.77190867,
            22.73996947, 24.14074627, 24.17323127, 24.16958127, 22.39190267,
            22.39190267, 19.84614887, 19.8314272, 19.84249887, 19.81402887,
            19.83884887, 22.6723284, 23.60669653, 23.6195932, 23.6141182,
            23.62093153, 25.0766732, 22.65905667, 23.76420733, 25.1292332,
            25.939687, 25.77373367, 25.95818033, 24.52861953, 25.3245412,
            25.99491173, 25.02654653, 25.20412487, 24.31073687, 25.13117987,
            25.03567153, 25.91128487, 25.20777487, 24.7763192, 25.4935032,
            26.3553682, 25.01851653, 24.29029687, 24.3485752, 25.0748482,
            25.10781987]  # M values
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用SimHei字体
plt.rcParams['axes.unicode_minus'] = False  # 正确显示负号#比赛结束前最后两天售后群发布无水印可视化结果+无标注代码【可直接提交】为了防止倒卖，论文写作过程中遗留数个致命问题，无关代码，该问题解决方式仅在官网授权售后群答疑，盗卖方式购买资料不提供答疑。因倒卖导致无法解决漏洞、赛后无法获奖等 本数模社概不负责  感谢理解 资料助攻购买链接+说明https://docs.qq.com/doc/p/88456ad269539fdd2e3da75b1e53defa66b5c3da
# 创建一个图形窗口
plt.figure(figsize=(10, 6))

# 绘制线图
plt.plot(resident_ids, m_values, 'o-', color='blue', linewidth=2, markersize=6, markerfacecolor='red')

# 添加图表标题和轴标签
plt.title('性价比 m 随着 ResidentPlotID 剔除的变化', fontsize=14)
plt.xlabel('ResidentPlotID', fontsize=12)
plt.ylabel('性价比 m', fontsize=12)

# 使图表更加美观
plt.grid(True)
plt.xticks(rotation=45, fontsize=10)
plt.yticks(fontsize=10)

# 显示图形
plt.tight_layout()
plt.show()
