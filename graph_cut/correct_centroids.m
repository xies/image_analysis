function cellsi = correct_centroids(cellsi, energy, centroids)
% CORRECT_CENTROIDS Takes an undersegmented image and further segments it so
%as to fit the cells to their centroids.

repeat = 1;
while repeat
    repeat = 0;
    cellsinv = ~cellsi;
    
    regions = bwlabel(cellsinv, 4);
    
    % Keep track of which one is the "background."
    background = -1;
    background_count = 0;
    
    centroid_track = zeros(1, length(unique(regions)) - 1);
    
    for centroid=centroids'
        cellnum = regions(round(centroid(1)), round(centroid(2)));
        centroid_track(cellnum) = centroid_track(cellnum) + 1;
        count = length(regions(regions == cellnum));
        if count > background_count
            background_count = count;
            background = cellnum;
        end
    end
    original = cellsi;
    for region=unique(regions)'
        if region > 0
            n = centroid_track(region);
            if n == 0
                % Empty - need to remove cell.
                % Trick: white-out the region, tn re-skeletonize later.
                cellsi = cellsi + (regions == region);
            elseif n == 1
                % Region is good, so do nothing.
            else
                % Too many centroids! Split them.
                if region == background
                    % For now, ignore.
                    % @TODO we need a way to deal with this.
                else
                    % Split!
                    cellsi = correct_centroids_split(cellsi, energy, centroids, regions, region);
                    repeat = 1;
                end
            end
        end
    end
    figure, imshow(cellsi - 0.75 * original);
end

cellsi = bwmorph(cellsi, 'shrink', Inf);
cellsi = bwmorph(cellsi, 'clean');

figure, imshow(cellsi);

h = max(max(energy));
l = min(min(energy));
normal = 1.0 - ((energy - l) / (h - l));

[x y] = size(cellsi);
newimg = zeros(x, y, 3);
for i=1:x
    for j=1:y
        newimg(i, j, :) = normal(i, j);
        if cellsi(i, j)
            newimg(i, j, :) = [1 0 0];
        end
    end
end
figure, imshow(newimg);

end