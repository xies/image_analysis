/*
 * An object to be sorted for PriorityQueue implementation of A* algorithm
 * 
 * xies@mit 2014
 */
public class Node {
	// index is the linearized index
	// gscore is the updated gscore
	public int index;
	public double gscore;
	
	public Node (int index, double gscore) {
		this.index = index;
		this.gscore = gscore;
	}
}
