package View;

import javax.swing.*;
import java.awt.*;

public class RobotViewer
        extends JComponent
{
    private enum LookDirection
    {
        NORTH,
        EAST,
        SOUTH,
        WEST;
        
        private static int[] northXCoords = {10, 25, 40};
        private static int[] eastXCoords  = {10, 40, 10};
        private static int[] southXCoords = {10, 25, 40};
        private static int[] westXCoords  = {40, 10, 40};
        
        private static int[] northYCoords = {40, 10, 40};
        private static int[] eastYCoords  = {10, 25, 40};
        private static int[] southYCoords = {10, 40, 10};
        private static int[] westYCoords  = {40, 25, 10};
        
        int[] xCoords()
        {
            switch (this)
            {
                case NORTH:
                    return northXCoords;
                case EAST:
                    return eastXCoords;
                case SOUTH:
                    return southXCoords;
                case WEST:
                    return westXCoords;
            }
            
            return null;
        }
        
        int[] yCoords()
        {
            switch (this)
            {
                case NORTH:
                    return northYCoords;
                case EAST:
                    return eastYCoords;
                case SOUTH:
                    return southYCoords;
                case WEST:
                    return westYCoords;
            }
            
            return null;
        }
    
        LookDirection Next()
        {
            switch (this)
            {
                case NORTH:
                    return EAST;
                case EAST:
                    return SOUTH;
                case SOUTH:
                    return WEST;
                case WEST:
                    return NORTH;
            }
    
            return null;
        }
    
        LookDirection Previous()
        {
            switch (this)
            {
                case NORTH:
                    return WEST;
                case EAST:
                    return NORTH;
                case SOUTH:
                    return EAST;
                case WEST:
                    return SOUTH;
            }
        
            return null;
        }
    }
    
    
    static int SideLength = 50;
    
    
    private LookDirection _lookDirection;
    
    
    RobotViewer()
    {
        _lookDirection = LookDirection.NORTH;
    }
    
    void TurnLeft()
    {
        _lookDirection = _lookDirection.Previous();
        repaint();
    }
    
    void TurnRight()
    {
        _lookDirection = _lookDirection.Next();
        repaint();
    }
    
    
    @Override
    protected void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        g.setColor(Color.black);
        g.fillPolygon(_lookDirection.xCoords(), _lookDirection.yCoords(), 3);
    }
    
    @Override
    public Dimension getPreferredSize()
    {
        return new Dimension(SideLength, SideLength);
    }
    
    @Override
    public Dimension getMaximumSize()
    {
        return new Dimension(SideLength, SideLength);
    }
    
    @Override
    public Dimension getMinimumSize()
    {
        return new Dimension(SideLength, SideLength);
    }
}
