function cellsi = split_region(cellsi, energy, centroids, regions, ID2split)

region_mask = (regions == ID2split);
figure, imshow(region_mask);

region_centroids = [];
for centroid=centroids'
    if regions(round(centroid(1)), round(centroid(2))) == ID2split
        region_centroids(end + 1, :) = centroid;
    end
end

% num_centroids = size(region_centroids, 1);
distances = dist(region_centroids');

% closest = find(distances == min(distances(find(distances))));
% closest = closest(1);
% % Centroids a and b are the closest two centroids in the region.
% centroid_a = region_centroids(ceil(closest / 4), :);
% centroid_b = region_centroids(mod(closest, 4), :);

distances( ~triu(distances) ) = Inf;
[I,J] = find(distances == min(distances(:)));
centroid_a = region_centroids(I,:);
centroid_b = region_centroids(J,:);

% General idea: find two closest centroids, prepare guideline "cut", find
% border intersection, find least-cost path from border intersection point
% 1 to border intersection point 2.

mid = (centroid_a + centroid_b) / 2;
angle = atan2((centroid_a(1) - centroid_b(1)), (centroid_a(2) - centroid_b(2)));
vector = [sin(angle + pi/2) cos(angle + pi/2)];

intersect = zeros(2, 2);

for i = 1:2
    pt = mid;

    while cellsi(round(pt(1)), round(pt(2))) == 0 && ...
            cellsi(round(pt(1)) + 1, round(pt(2))) == 0 && ...
            cellsi(round(pt(1)), round(pt(2)) + 1) == 0 && ...
            cellsi(round(pt(1)) - 1, round(pt(2))) == 0 && ...
            cellsi(round(pt(1)), round(pt(2)) - 1) == 0
%     while cellsi(round(pt(1)), round(pt(2))) == 0
        pt = pt + vector;
    end
    intersect(i, :) = round(pt);
    vector = vector * -1;
end

h = max(max(energy));
l = min(min(energy));
normalized_energy = 1.0 - ((energy - l) / (h - l));
intmap = reshape(1:numel(energy),[size(energy,2), size(energy,1)])';
path = find_min_path(normalized_energy, intmap, intersect(1, :), intersect(2, :));

for point=path'
    cellsi(point(1), point(2)) = 1;
end

end
