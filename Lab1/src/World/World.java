package World;

public class World
{
    private int[][] _walls;


    public World(int[][] wallCoordinates)
    {
        _walls = wallCoordinates;
    }


    public int[][] GetWallsCoordinates()
    {
        return _walls;
    }
}
