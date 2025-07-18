% 读取图像
img = imread('path_to_image.jpg'); % 替换为图像文件的路径

% 将图像转换为灰度图像
grayImg = rgb2gray(img);

% 进行二值化处理
bwImg = imbinarize(grayImg);

% 使用OCR提取数字
ocrResults = ocr(bwImg);

% 显示图像
imshow(img);
title('Click on the image to get coordinates');

% 通过点击获取坐标
% 这里设定最多获取10个点击点的坐标，你可以修改该值
numClicks = 107;
[x, y] = ginput(numClicks);

% 显示点击坐标
for i = 1:length(x)
    % 在图像上标记坐标
    hold on;
    plot(x(i), y(i), 'ro'); % 在点击位置绘制红色圆点
    text(x(i) + 10, y(i) + 10, sprintf('(%0.2f, %0.2f)', x(i), y(i)), ...
        'Color', 'blue', 'FontSize', 12, 'FontWeight', 'bold');
end

% 打印所有点击的坐标
for i = 1:length(x)
    fprintf('Click %d: (%.2f, %.2f)\n', i, x(i), y(i));
end