im03 = mat2gray(imread('~/Dropbox/segmentation test images/test_t003.tif'));
im04 = mat2gray(imread('~/Dropbox/segmentation test images/test_t004.tif'));

im42 = mat2gray(imread('~/Dropbox/segmentation test images/twist_t042.tif'));
im43 = mat2gray(imread('~/Dropbox/segmentation test images/twist_t043.tif'));

im01 = mat2gray(imread('~/Dropbox/segmentation test images/twist_t001.tif'));
im02 = mat2gray(imread('~/Dropbox/segmentation test images/twist_t002.tif'));

im49 = mat2gray(imread('~/Dropbox/segmentation test images/test_t049.tif'));
im50 = mat2gray(imread('~/Dropbox/segmentation test images/test_t050.tif'));

%% compute background mask

I = im42;
t = 30;
embryoID = 6;

cx = centroids_x(t,[IDs.which] == embryoID)/input(embryoID).um_per_px;
cy = (centroids_y(t,[IDs.which] == embryoID) + input(embryoID).yref)/input(embryoID).um_per_px;
centroids = cat(1,cy(~isnan(cx)),cx(~isnan(cx)))';

initial = get_membs_v3(I,2/.18,12/.18,1);

% bg = I;
% th = .1;
% bg(I >= th) = 0;
% border_obj = imclearborder(bg);
% bg = bg - border_obj;
% bg_mask = bwmorph(bg,'close');
% imshow(bg_mask)

%% Perform seeded watershed 

[x,y] = size(I);
fg_mask = accumarray(round(centroids),true,[x y]);
kernel = fspecial('gauss');
Ifilt = imfilter(I,kernel);

im_min = imimposemin(Ifilt, fg_mask);

L = watershed(im_min);
cellsI_watershed = L == 0; % watershed skeleton

% visualize results
figure(201)
I2disp = I(:,:,ones(1,3)); % rgb image
red = I2disp(:,:,1);
red(cellsI_watershed) = 1;
blue = I2disp(:,:,3);
blue(initial) = 1;
I2disp(:,:,2) = blue;
I2disp(:,:,1) = red;
imshow(I2disp)

hold on
scatter(centroids(:,2),centroids(:,1),'r*')

%% Perform graph cutting

initial = get_membs_v3(I,2/.18,12/.18,0);
[dirty,clean] = eliminate_bad_cells(initial, 100, 0);
% initial = cellsI_watershed;
energy = -I;
cellsI_graphcut = correct_centroids(clean,energy,centroids);

% visualize results
figure(202)
I2disp = I(:,:,ones(1,3)); % rgb image
red = I2disp(:,:,1);
red(cellsI_graphcut) = 1;
blue = I2disp(:,:,3);
blue(initial) = 1;
I2disp(:,:,2) = blue;
I2disp(:,:,1) = red;
imshow(I2disp)

hold on
scatter(centroids(:,2),centroids(:,1),'r*')

