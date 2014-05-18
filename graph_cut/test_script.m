
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
t = 10;
embryoID = 6;
um_per_px = .1410;

cx = load(['~/Dropbox/segmentation test images/embryo' num2str(embryoID) '_cx']);
cy = load(['~/Dropbox/segmentation test images/embryo' num2str(embryoID) '_cy']);

cx = cx.data; cy = cy.data;
cx = squeeze(cell2mat(cx(:,1,:)))/um_per_px;
cy = squeeze(cell2mat(cy(:,1,:)))/um_per_px;

cx = cx(t,:); cy = cy(t,:);

centroids = cat(1,cy(~isnan(cx)),cx(~isnan(cx)))';

initial = get_membs_v3(I,2/um_per_px,12/um_per_px,1);

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

initial = get_membs_v3(I,2/um_per_px,12/um_per_px,0);
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

