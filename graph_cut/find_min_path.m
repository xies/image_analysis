function path = find_min_path(weight, intmap, start, goal)
%FIND_MIN_PATH  Finds the minimum path (weighted by weight) from the start
% point to the end point. Implements the A* search algorithm.
%
% USAGE: path = find_min_path(weight,intmap,start,goal);
%
% INPUT: weight - the cost function minimized by path
%        intmap - linearized index of the lattice
%        start - indices (x,y) of the start
%        goal - indices (x,y) of the goal
%
% Authors:
% Charlie Gordon @ mit
% xies@mit

tic
% Import some useful Java classes for faster computation time.
import java.util.PriorityQueue;
import findMinPath.*;
 
% Should never happen... but here just in case for robustness.
if (start(1) == goal(1) && start(2) == goal(2))
    path = goal;
    return
end

% This improves the heuristic greatly and speeds up the algorithm.
k = 4; % Sharpness
% oweight = weight; % original weights
a = graythresh(weight); % Threshold
weight = (weight .^ k) ./ ((weight .^ k) + (a ^ k));
weight(isnan(weight)) = Inf;

w = 5;
% Higher values care more about energy; lower values care more about distance.
% Higher values are also much slower since more points need to be
% investigated more times.

weight = w * weight;

[x,y] = size(weight);

% Using A* search algorithm:
closedset = zeros(x, y);

opensetarray = zeros(x, y);
% This is a hack used so that we can use Java's PriorityQueue for faster
% performance. Use Node object to keep track of pixel position and cost
comparator = CostComparator(goal(1), goal(2), x, y);
openset = PriorityQueue(11, comparator);
openset.add( Node(intmap(start(1), start(2)), 0) );
opensetarray(start(1), start(2)) = 1;
 
came_from_x = zeros(x, y);
came_from_y = zeros(x, y);
 
g_score = zeros(x, y);

% Initialize with our starting point.
% The "g" score is the cost-so-far of reaching this node.
g_score(start(1), start(2)) = 0;

neighbors = [0 1 0 -1 1 -1 1 -1
             1 0 -1 0 1 1 -1 -1];
 
% Now, iterate until we reach our goal.
% xies: The control flow is awkward: while/return

while ~openset.isEmpty()
    % Start with the lowest-cost point currently in our open set, since
    % this cannot possibly get smaller by expanding any of its neighbors,
    % but could potentially make its neighbors' costs smaller by its
    % expansion.
    currentmapped = openset.poll();
    currentmapped = currentmapped.index;
    % Reverse the hash to get the indices.
    current = [ceil(currentmapped / y) mod(currentmapped - 1, y) + 1];
 
    % If we've reached the goal, we're done.
    if current(1) == goal(1) && current(2) == goal(2)
        current_node = [came_from_x(goal(1), goal(2)) came_from_y(goal(1), goal(2))];
 
        path = [goal; current_node];
        % Retrace our steps and add them to the path.
        while came_from_x(current_node(1), current_node(2)) ...
                && came_from_y(current_node(1), current_node(2))
            
            current_node = [came_from_x(current_node(1), ...
                current_node(2)) came_from_y(current_node(1), ...
                current_node(2))];
            path = union(path, current_node, 'rows');
            
        end
        % Now, we're done, so return.
        toc
        return;
    end
 
    % Remove the current node from the open set and put it in the closed
    % set.
    openset.remove( currentmapped );
    opensetarray(current(1), current(2)) = 0;
    closedset(current(1), current(2)) = 1;
 
    % Expand all of its neighbors.
    for ij = neighbors
        % Unless they are the current node itself, or beyond the
        % boundaries of the image.
        if current(1) + ij(1) >= 1 && ...
                current(1) + ij(1) <= x && ...
                current(2) + ij(2) >= 1 && ...
                current(2) + ij(2) <= y
            neighbor = current + ij';
            % Also don't expand if this neighbor is already in the
            % closed set.
            if closedset(neighbor(1), neighbor(2))
                continue;
            end
            
            % Calculate a tentative g score. This score will only get
            % used if it's actually better than any previous g score.
            if abs(ij(1)) == abs(ij(2))
                factor = 0.70710678; % sqrt(1/2);
            else
                factor = 0.5;
            end
            
            tentative_g_score = ...
                g_score(current(1), current(2)) + ... % g_score to tip of path
                factor * weight(current(1), current(2)) + ... % current weight 
                factor * weight(neighbor(1), neighbor(2)); % neighbor's weight
 
            % If it doesn't have a score yet, we use the tentative g
            % score.
            if ~opensetarray(neighbor(1), neighbor(2))
%             if openset.contains( Node(intmap(neighbor(1),neighbor(2)),0 ) )
                tentative_is_better = 1;
            % Also, if the score is better than the previous score, we
            % use the tentative g score.
            elseif tentative_g_score < g_score(neighbor(1), neighbor(2))
                
%                 before = openset.size;
                openset.remove( ...
                    Node( intmap(neighbor(1), neighbor(2)), ...
                    g_score( neighbor(1),neighbor(2) ) ) );
%                 if before >= openset.size
%                     keyboard;
%                 end
                
                tentative_is_better = 1;
            % Otherwise, we do not use the tentative g score.
            else
                tentative_is_better = 0;
            end
 
            % If we used the tentative g score, update variables as
            % needed.
            if tentative_is_better
                % Keep track of the node's predecessors so we can
                % retrace our steps at the end.
                came_from_x(neighbor(1), neighbor(2)) = current(1);
                came_from_y(neighbor(1), neighbor(2)) = current(2);
                % Update the comparator's knowledge of g scores.
%                 comparator.setG(intmap(neighbor(1), neighbor(2)), tentative_g_score);
                % Add (or re-add) this node to the open set. It is
                % necessary to re-add if it was already there so the
                % PriorityQueue updates its ordering.
                openset.add(...
                    Node( intmap(neighbor(1), neighbor(2)), ...
                    tentative_g_score) );
%                     factor * weight(neighbor(1),neighbor(2)) ) );
                opensetarray(neighbor(1), neighbor(2)) = 1;
                % Finally, save the g score.
                g_score(neighbor(1), neighbor(2)) = tentative_g_score;
            end
        end
    end
end