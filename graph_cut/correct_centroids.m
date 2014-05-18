function [cellsi,regions] = correct_centroids(cellsi, energy, centroids)
% CORRECT_CENTROIDS Takes an undersegmented image and further segments it so
% as to fit the cells to their centroids.
% 
% SYNOPSIS: outlines = correct_centroids(underseg, energy, centroids);
%

% get rid of NaN entries in centroids
centroids = centroids(:,~isnan(centroids(1,:)));

repeat = 1;
initial = cellsi;

% whiteout = false(size(cellsi));

while repeat
    
    repeat = 0;
    
    % regions keeps track of object label
    regions = bwlabel(~cellsi, 4);

    % Keep track of which one is the "background."
    background = -1;
    background_count = 0;
    
    centroid_track = zeros(1, length(unique(regions)) - 1);
    
    % Go thorugh every given centroid and put each centroid in a region in
    % the initial labelled image
    for i = 1:size(centroids,1)
        
        centroid = centroids(i,:);
        
        % centroid_track keeps track of how many centroids fell into a single
        % region
        cellnum = regions( round(centroid(1)), round(centroid(2)) );
        
        % edgecase when centroid is on top of a border
        if cellnum == 0
            while cellnum == 0
                %@TODO what if cellnum is 0? ie. centroid on border?
                % Try to move the centroid to left or right...?
                centroids(i,:) = [ centroid(1)-1 centroid(2) ];
                centroid = centroids(i,:);
                cellnum = regions( round(centroid(1)), round(centroid(2)) );
            end
        end
        centroid_track(cellnum) = centroid_track(cellnum) + 1;
        count = length(regions(regions == cellnum));
        % @TODO define background as the region with most centroids -
        % need to fix!
        if count > background_count
            background_count = count;
            background = cellnum;
        end
    end
    
    original = cellsi;
    for region = unique(regions)'
        if region > 0
            
            n = centroid_track(region);
            
            if n == 0
                % Empty - need to remove cell.
                % Trick: white-out the region, tn re-skeletonize later.
                cellsi = cellsi + (regions == region);
%                 whiteout = whiteout | regions == region;
                
                
            elseif n == 1
                % Region has only one centroid so do nothing.
            else
                % Too many centroids! Split them.
                if region == background
                    % For now, ignore.
                    % @TODO we need a way to deal with this.
                else
                    % Split!
                    try [cellsi,intersection] = split_region(cellsi, energy, centroids, regions, region);
                    catch exception
                        if strcmpi(exception.identifier,'split_region:GuidelineCollapse')
                            repeat = 0;
                            continue
                        end
                    end
                    repeat = 1;
%                     figure, imshow(cellsi - 0.75 * original);
%                     hold on
%                     scatter(intersection(1,2),intersection(1,1),'r*')
%                     scatter(intersection(2,2),intersection(2,1),'r*')
%                     keyboard
                end
            end
        end
    end
%     if all(all(original == cellsi)), keyboard; end
%     figure, imshow(cellsi - 0.75 * original);
end

% idx2elim = unique(regions(whiteout));
% [dirty,clean] = eliminate_region(regions,idx2elim,background-1);

% perimeter = bwmorph(cellsi,'open');
% filled = imfill(~bwmorph(cellsi,'open'),'holes');
% holes = filled - ~perimeter;

perimeter = bwmorph(cellsi,'open');
perimeter = imfill(~perimeter,'holes');
perimeter = bwperim(perimeter);

cellsi = perimeter | bwperim(cellsi);

% fill in interior holes
% cellsi = imfill(~cellsi,'holes');

cellsi = bwmorph(cellsi, 'shrink', Inf);
cellsi = bwmorph(cellsi, 'clean');

regions = bwlabel(~cellsi,4);

% figure, imshow(cellsi);

% h = max(max(energy));
% l = min(min(energy));
% normal = 1.0 - ((energy - l) / (h - l));

% [x,y] = size(cellsi);
% newimg = zeros(x, y, 3);
% for i=1:x
%     for j=1:y
%         newimg(i, j, :) = normal(i, j);
%         if cellsi(i, j)
%             newimg(i, j, :) = [1 0 0];
%         end
%         if initial(i,j)
%             newimg(i,j,3) = 1;
%         end
%     end
% end
% figure, imshow(newimg);
% hold on;
% scatter(centroids(:,2),centroids(:,1),'r*');

end
