%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Matlab Lab Testat Winter Term 2025/26                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
%%%% Read in a test image with a door %%%%%

% First test image 
image = imread('./01 - R2441 - i.JPG');
[M N C] = size(image);
figure(1),imshow(image,'Border','tight');

% Second test image
%image = imread('./01 - R2442 - i.JPG');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: Image Preprocessing - Contrast Adjustment, Noise Reduction      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

%%%% Conversion to Gray Value Image %%%%
if size(image,3) == 3
    img_gray = rgb2gray(image);
else
    img_gray = image;
end

%%%% Adjust Contrast %%%%
lowhigh = stretchlim(img_gray, [0.01 0.99]);
img_contrast = imadjust(img_gray, lowhigh, []);

%%%% Noise reduction via binomial low-pass filtering %%%%
k = [1 4 6 4 1] / 16;
tmp = imfilter(img_contrast, k,  'replicate', 'same');   
img = imfilter(tmp,        k', 'replicate', 'same');     

%figure, imshow(img_gray), title('Gray');
%figure, imshow(img_contrast), title('Contrast adjusted');
%figure, imshow(img), title('Binomial filtered');

img = uint8(img);
 
%%%% If you have no result load the given one %%%%

%load('Solutions_Task_1.mat')
%figure(1),imshow(img,'Border','tight');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 2: Feature Extraction - Contours                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Work in double to avoid overflow/clipping
imgd = double(img);

imgd = imgaussfilt(imgd, 1.0);

%%%% Optimized Sobel x %%%%
v  = [1; 3; 1];
hx = [-3 0 3];

img_sobel_x = (1/32) * imfilter(imfilter(imgd, v, 'replicate','same'), hx, 'replicate','same');

%%%% Edge Strength (x) %%%%
img_edge_strength_x = abs(img_sobel_x);

% Negative x-Gradients (bright to dark)
k = 3.0;
T_x = k * mean(img_edge_strength_x(:));

img_neg_edge_x = (img_sobel_x < -T_x);
img_neg_edge_x = bwareaopen(img_neg_edge_x, 30);
img_neg_edge_x = imclose(img_neg_edge_x, strel('diamond',1));
img_neg_edge_x = imdilate(img_neg_edge_x, strel('diamond',1));

% Positive x-Gradients (dark to bright)
img_pos_edge_x = (img_sobel_x > T_x);
img_pos_edge_x = bwareaopen(img_pos_edge_x, 30);
img_pos_edge_x = imclose(img_pos_edge_x, strel('diamond',1));
img_pos_edge_x = imdilate(img_pos_edge_x, strel('diamond',1));

%%%% Optimized Sobel y %%%%
h  = [1 3 1];
vy = [-3; 0; 3];

img_sobel_y = (1/32) * imfilter(imfilter(imgd, vy, 'replicate','same'), h, 'replicate','same');

% Negative y-Gradients (bright to dark)
img_edge_strength_y = abs(img_sobel_y);
T_y = k * mean(img_edge_strength_y(:));

img_neg_edge_y = (img_sobel_y < -T_y);
img_neg_edge_y = bwareaopen(img_neg_edge_y, 30);
img_neg_edge_y = imclose(img_neg_edge_y, strel('diamond',1));
img_neg_edge_y = imdilate(img_neg_edge_y, strel('diamond',1));

% Positive y-Gradients (dark to bright)
img_pos_edge_y = (img_sobel_y > T_y);
img_pos_edge_y = bwareaopen(img_pos_edge_y, 30);
img_pos_edge_y = imclose(img_pos_edge_y, strel('diamond',1));
img_pos_edge_y = imdilate(img_pos_edge_y, strel('diamond',1));

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_2.mat')

%%%% Visualize Results %%%%
figure(2),imagesc(img_sobel_x); colorbar; colormap hsv; axis off;
figure(3),imagesc(log(1+img_edge_strength_x)); colorbar; axis off;
figure(4),imagesc(img_neg_edge_x); colorbar; colormap gray; axis off;
figure(5),imagesc(img_pos_edge_x); colorbar; colormap gray; axis off;
figure(6),imagesc(img_neg_edge_y); colorbar; colormap gray; axis off;
figure(7),imagesc(img_pos_edge_y); colorbar; colormap gray; axis off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 3: Segmentation of Door Gap Contour                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...
I = double(img);

% Extract Vertical Edge candidates for %
strength_neg_x = double(img_neg_edge_x);
strength_pos_x = double(img_pos_edge_x);

% Design a symmetric filter %
sym_threshold = 0.1;
img_sym_x = (strength_neg_x + strength_pos_x) >= sym_threshold;

% Combine knowledge on gray value range and bright-to-dark gradients 
gray_th = mean(I(:));
candidates_x = img_sym_x & (I < gray_th);

% Fatten lines to improve detection 
candidates_x = imclose(candidates_x, strel('line', 2, 90));
candidates_x = imdilate(candidates_x, strel('diamond', 1));

% Extract Horizontal Edge candidates 
strength_neg_y = double(img_neg_edge_y);
strength_pos_y = double(img_pos_edge_y);

img_sym_y = (strength_neg_y + strength_pos_y) >= sym_threshold;

% Combine knowledge on absolute gray value and bright-to-dark-gradient
candidates_y = img_sym_y & (I < gray_th);

% Fatten lines to improve detection 
candidates_y = imclose(candidates_y, strel('line', 1, 0));
candidates_y = imdilate(candidates_y, strel('diamond', 2));

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_3.mat')

%%%% Visualize Results %%%%
figure(8), imagesc(max(img_sym_x(:)) - abs(img_sym_x)); colorbar; colormap gray; axis off;
figure(9), imagesc(1 - candidates_x); colorbar; colormap gray; axis off;
figure(10), imagesc(1 - candidates_y); colorbar; colormap gray; axis off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 4: Measuring Lines of the Door Gap                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...
BWx_thick = bwmorph(candidates_x, 'thicken', 1);
BWy_thick = bwmorph(candidates_y, 'thicken', 1);

% Compute Hough space for vertical lines
[H_vert, theta_vert, rho_vert] = hough(BWx_thick);

%%%% Find vertical Hough Lines %%%%
P_vert = houghpeaks(H_vert, 10, 'Threshold', 0.2 * max(H_vert(:)), 'NHoodSize', [7 7]);
lines_vert = houghlines(BWx_thick, theta_vert, rho_vert, P_vert, ...
    'FillGap', 10, ...
    'MinLength', 580);

N = size(I, 2);

xmid = zeros(1, numel(lines_vert));
for k = 1:numel(lines_vert)
    xmid(k) = (lines_vert(k).point1(1) + lines_vert(k).point2(1)) / 2;
end

[~, idxL] = min(xmid);
[~, idxR] = max(xmid);

pick = unique([idxL, idxR], 'stable');

% Transform two best candidates to Hesse Normalform
l_x = zeros(3, 2);
for kk = 1:min(2, numel(pick))
    k = pick(kk);

    x1 = lines_vert(k).point1(1);
    y1 = lines_vert(k).point1(2);
    x2 = lines_vert(k).point2(1);
    y2 = lines_vert(k).point2(2);

    a = y1 - y2;
    b = x2 - x1;
    c = x1 * y2 - x2 * y1;

    l_x(:, kk) = [a; b; c] / sqrt(a^2 + b^2);
end

%Compute Hough space for horizontal lines
[H_horz, theta_horz, rho_horz] = hough(BWy_thick);

%%%% Find horizontal Hough Lines %%%%
P_horz = houghpeaks(H_horz, 10, ...
    'Threshold', 0.2 * max(H_horz(:)), 'NHoodSize', [15 15]);

lines_horz = houghlines(BWy_thick, theta_horz, rho_horz, P_horz, ...
    'FillGap', 10, ...
    'MinLength', 600);

ymid = zeros(1, numel(lines_horz));
for k = 1:numel(lines_horz)
    ymid(k) = (lines_horz(k).point1(2) + lines_horz(k).point2(2)) / 2;
end

[~, idxL] = min(ymid);
[~, idxR] = max(ymid);

pick = unique([idxL, idxR], 'stable');

% Transform two best candidates to Hesse Normalform
l_y = zeros(3, 2);
for kk = 1:min(2, numel(pick))
    k = pick(kk);

    x1 = lines_horz(k).point1(1);
    y1 = lines_horz(k).point1(2);
    x2 = lines_horz(k).point2(1);
    y2 = lines_horz(k).point2(2);

    a = y1 - y2;
    b = x2 - x1;
    c = x1 * y2 - x2 * y1;

    l_y(:, kk) = [a; b; c] / sqrt(a^2 + b^2);
end

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_4.mat')

%%%% Visualize Results %%%%
figure(11), imshow(image, 'Border', 'tight'); hold on;

for k = 1:2
    plot([round(-(l_x(2, k) + l_x(3, k)) / l_x(1, k)); ...
          round(-(M * l_x(2, k) + l_x(3, k)) / l_x(1, k))], ...
         [1, M], ...
         'LineWidth', 1, 'Color', 'green'); hold on;
end

for k = 1:2
    plot([1, N], ...
         [round(-(l_y(1, k) + l_y(3, k)) / l_y(2, k)); ...
          round(-(N * l_y(1, k) + l_y(3, k)) / l_y(2, k))], ...
         'LineWidth', 1, 'Color', 'green'); hold on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 5: Measure and Classify Corner Points                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

% Find left and right door gap lines %
xpos = zeros(1,2);
for k = 1:2
    xpos(k) = -(l_x(2,k) + l_x(3,k)) / l_x(1,k);
end

[~, idxL] = min(xpos);
[~, idxR] = max(xpos);

l_x_left  = l_x(:, idxL);
l_x_right = l_x(:, idxR);

% Find up and down door gap lines %
ypos = zeros(1,2);
for k = 1:2
    ypos(k) = -(l_y(1,k) + l_y(3,k)) / l_y(2,k);
end

[~, idxU] = min(ypos);
[~, idxD] = max(ypos);

l_y_up   = l_y(:, idxU);
l_y_down = l_y(:, idxD);

% Find corner points %
A = [l_x_left(1:2)'; l_y_down(1:2)'];
B = -[l_x_left(3); l_y_down(3)];
lb = A \ B;

A = [l_x_left(1:2)'; l_y_up(1:2)'];
B = -[l_x_left(3); l_y_up(3)];
lu = A \ B;

A = [l_x_right(1:2)'; l_y_up(1:2)'];
B = -[l_x_right(3); l_y_up(3)];
ru = A \ B;

A = [l_x_right(1:2)'; l_y_down(1:2)'];
B = -[l_x_right(3); l_y_down(3)];
rb = A \ B;

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_5.mat')
%%%% Visualize Results %%%%
figure(12),imshow(image,'Border','tight');hold on;
plot([round(-(l_x_left(2)+l_x_left(3))/l_x_left(1)); round(-(M*l_x_left(2)+l_x_left(3))/l_x_left(1));],...
    [1,M],...
    'LineWidth',1,'Color','red');hold on;
plot([round(-(l_x_right(2)+l_x_right(3))/l_x_right(1)); round(-(M*l_x_right(2)+l_x_right(3))/l_x_right(1));],...
    [1,M],...
    'LineWidth',1,'Color','green');hold on;
plot([1,N],...
    [round(-(l_y_up(1)+l_y_up(3))/l_y_up(2)); round(-(N*l_y_up(1)+l_y_up(3))/l_y_up(2));],... 
    'LineWidth',1,'Color','red');hold on;
plot([1,N],...
    [round(-(l_y_down(1)+l_y_down(3))/l_y_down(2)); round(-(N*l_y_down(1)+l_y_down(3))/l_y_down(2));],... 
    'LineWidth',1,'Color','green');hold on;
plot(lb(1),lb(2),'ro','MarkerFaceColor','r');hold on;
plot(lu(1),lu(2),'go','MarkerFaceColor','g');hold on;
plot(ru(1),ru(2),'bo','MarkerFaceColor','b');hold on;
plot(rb(1),rb(2),'ko','MarkerFaceColor','k');hold on;
