im03 = mat2gray(imread('~/Dropbox/segmentation test images/test_t003.tif'));
im04 = mat2gray(imread('~/Dropbox/segmentation test images/test_t004.tif'));

im49 = mat2gray(imread('~/Dropbox/segmentation test images/test_t049.tif'));
im50 = mat2gray(imread('~/Dropbox/segmentation test images/test_t050.tif'));

%% compute background mask
I = im50;
cx = centroids_x(49,:);
cy = centroids_y(49,:);
centroids = cat(1,cy(~isnan(cx)),cx(~isnan(cx)))';

bg = I;
th = graythresh(I);
bg(I >= th) = 0;
border_obj = imclearborder(bg);
bg = bg - border_obj;
bg_mask = bwmorph(bg,'close');
imshow(bg_mask)

%% Perform seeded watershed 

[x,y] = size(I);
fg_mask = accumarray(round(centroids),true,[x y]);
kernel = fspecial('gauss');
Ifilt = imfilter(I,kernel);

im_min = imimposemin(Ifilt, bg_mask | fg_mask);

L = watershed(im_min);
cellsI_watershed = L == 0; % watershed skeleton

% visualize results
figure(201)
I2disp = I(:,:,ones(1,3)); % rgb image
red = I2disp(:,:,1);
red(cellsI_watershed) = 1;
I2disp(:,:,1) = red;
imshow(I2disp)
hold on
scatter(centroids(:,2),centroids(:,1),'r*')

%% Perform graph cutting

initial = get_membs_v3(I,1.5/.2,15/.2,1.5);
% initial = cellsI_watershed;
energy = I;
cellsI_graphcut = correct_centroids(initial,energy,centroids);

% visualize results
figure(202)
I2disp = I(:,:,ones(1,3)); % rgb image
red = I2disp(:,:,1);
red(cellsI_graphcut) = 1;
I2disp(:,:,1) = red;
imshow(I2disp)


