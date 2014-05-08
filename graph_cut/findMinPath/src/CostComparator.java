import java.util.Comparator;
/* Comparator for using PriorityQueue to implement a A* algorithm to search
 * for a cost-minimizing path from a start point to a goal point through a graph.
 * 
 * Basically uses the image index from Node to calculate the distance of that
 * object to the goal position, and add the cost function (gscore) to this distance.
 * 
 * Charlie Gordon @ MIT, 2012
 * xies @ mit, 2014
 */
public class CostComparator implements Comparator<Node> {
	
	private int goalX;
	private int goalY;
	private int dimX;
	private int dimY;

	public CostComparator(int goalX, int goalY, int dimX, int dimY) {
		this.goalX = goalX;
		this.goalY = goalY;
		this.dimX = dimX;
		this.dimY = dimY;
	}

	public int compare(Node a, Node b) {
		
			int ax = (int) Math.ceil(a.index / dimY);
			int ay = ((int) (a.index - 1) % dimY) + 1;
			int bx = (int) Math.ceil(b.index / dimY);
			int by = ((int) (b.index - 1) % dimY) + 1;

			double adist = Math.sqrt((goalX - ax) * (goalX - ax) + (goalY - ay) * (goalY - ay));
			double bdist = Math.sqrt((goalX - bx) * (goalX - bx) + (goalY - by) * (goalY - by));

			adist = adist + a.gscore;
			bdist = bdist + b.gscore;

			if (adist > bdist) {return 1;}
			else if (adist == bdist) {return 0;}
			else {return -1;}
			
	}

}