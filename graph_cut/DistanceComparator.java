import java.util.Comparator;

public class DistanceComparator implements Comparator<Double> {
	private int goalX;
	private int goalY;
	private int dimX;
	private int dimY;

	public DistanceComparator(int goalX, int goalY, int dimX, int dimY) {
		this.goalX = goalX;
		this.goalY = goalY;
		this.dimX = dimX;
		this.dimY = dimY;
	}

	@Override
	public int compare(Double a, Double b) {
		int ax = (int) Math.ceil(a / dimY);
		int ay = ((int) (a - 1) % dimY) + 1;
		int bx = (int) Math.ceil(b / dimY);
		int by = ((int) (b - 1) % dimY) + 1;
		double adist = Math.sqrt((goalX - ax) * (goalX - ax) + (goalY - ay) * (goalY - ay));
		double bdist = Math.sqrt((goalX - bx) * (goalX - bx) + (goalY - by) * (goalY - by));
		if (adist > bdist) {
			return 1;
		}
		else if (adist == bdist) {
			return 0;
		}
		else {
			return -1;
		}
	}
}

