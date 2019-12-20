package World;

import java.util.ArrayList;
import java.util.Arrays;

public class World
{
    private int _sizeX;
    private int _sizeY;
    
    private ArrayList<int[]> _walls;
    private ArrayList<int[]> _markers;

    public World(int sizeX, int sizeY, int[][] wallCoordinates, int[][] markerCoordinates)
    {
        _sizeX = sizeX;
        _sizeY = sizeY;
        
        _walls = new ArrayList<>(Arrays.asList(wallCoordinates));
        _markers = new ArrayList<>(Arrays.asList(markerCoordinates));
    }


    public ArrayList<int[]> GetWallsCoordinates()
    {
        return _walls;
    }
    public ArrayList<int[]> GetMarkersCoordinates()
    {
        return _markers;
    }


    public boolean IsTileMovable(int x, int y)
    {
        //If input is invalid
        if (0 > x || x >= _sizeX || 0 > y || y >= _sizeY)
            return false;
        
        //If tile has wall
        if (_walls.stream().anyMatch((int[] e) -> e[0] == x && e[1] == y))
            return false;
    
        return true;
    }
    
    public boolean TileHasMarker(int x, int y)
    {
        return _markers.stream().anyMatch((int[] e) -> e[0] == x && e[1] == y);
    }
    
    public boolean RemoveMarker(int x, int y)
    {
        return _markers.removeIf(e -> e[0] == x && e[1] == y);
    }
    
    public boolean AddMarker(int x, int y)
    {
        if (TileHasMarker(x, y))
            return false;
        
        _markers.add( new int[]{x, y} );
        
        return true;
    }
}
