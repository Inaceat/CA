package World;

public class World
{
    private int[][] _walls;
    private int[][] _markers;

    public World(int[][] wallCoordinates, int[][] markerCoordinates)
    {
        _walls = wallCoordinates;
        _markers = markerCoordinates;
    }


    public int[][] GetWallsCoordinates()
    {
        return _walls;
    }
    public int[][] GetMarkersCoordinates()
    {
        return _markers;
    }
}
