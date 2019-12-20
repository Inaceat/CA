package Robot.Hardware;

import World.World;

public class Chassis
{
    public enum LookDirection
    {
        North,
        East,
        South,
        West;
    
        LookDirection Next()
        {
            switch (this)
            {
                case North:
                    return East;
                case East:
                    return South;
                case South:
                    return West;
                case West:
                    return North;
            }
    
            return null;
        }
    
        LookDirection Previous()
        {
            switch (this)
            {
                case North:
                    return West;
                case East:
                    return North;
                case South:
                    return East;
                case West:
                    return South;
            }
        
            return null;
        }
    }
    
    private World _world;
    
    private int _currentX;
    private int _currentY;
    
    private LookDirection _direction;
    
    private int _markersCount;
    
    
    public Chassis(World world, int initialX, int initialY, LookDirection lookDirection)
    {
        _world = world;
        
        _currentX = initialX;
        _currentY = initialY;
        
        _direction = lookDirection;
        
        _markersCount = 0;
    }
    

    public int GetXCoordinate()
    {
        return _currentX;
    }
    public int GetYCoordinate()
    {
        return _currentY;
    }

    public int GetMarkersCount()
    {
        return _markersCount;
    }


    public boolean MoveForward()
    {
        switch (_direction)
        {
            case North:
            {
                if (_world.IsTileMovable(_currentX, _currentY - 1))
                    _currentY -= 1;
                else
                    return false;
            }break;
                
            case East:
            {
                if (_world.IsTileMovable(_currentX + 1, _currentY))
                    _currentX += 1;
                else
                    return false;
            }break;
            
            case South:
            {
                if (_world.IsTileMovable(_currentX, _currentY + 1))
                    _currentY += 1;
                else
                    return false;
            }break;
                
            case West:
            {
                if (_world.IsTileMovable(_currentX - 1, _currentY))
                    _currentX -= 1;
                else
                    return false;
            }break;
        }
        
        return true;
    }
    
    public void TurnLeft()
    {
        _direction = _direction.Previous();
    }
    
    public void TurnRight()
    {
        _direction = _direction.Next();
    }
    
    public boolean PlaceMarker()
    {
        if (_markersCount > 0)
        {
            var markerAdded = _world.AddMarker(_currentX, _currentY);
            
            if (markerAdded)
                --_markersCount;
            
            return markerAdded;
        }
        
        return false;
    }
    
    public boolean RemoveMarker()
    {
        var markerRemoved = _world.RemoveMarker(_currentX, _currentY);
        
        if (markerRemoved)
            ++_markersCount;
        
        return markerRemoved;
    }
}
