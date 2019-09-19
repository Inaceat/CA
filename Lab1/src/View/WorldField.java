package View;

import javax.swing.*;
import java.awt.*;

class WorldField
        extends JPanel
{
    private WorldTile[][] _fieldData;
    
    private int _tileSize;
    private int _sidePixels;
    
    WorldField(int size)
    {
        super(true);
        
        setLayout(new GridLayout(size, size));
        
        _fieldData = new WorldTile[size][size];
    
        _tileSize = size;
        _sidePixels = size * WorldTile.SideLength;
    
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                _fieldData[i][j] = new WorldTile(new Color((int)(Math.random() * 0x1000000)));
                add(_fieldData[i][j]);
            }
        }
    }
    
    @Override
    public Dimension getPreferredSize()
    {
        return new Dimension(_sidePixels, _sidePixels);
    }
    
    @Override
    public Dimension getMaximumSize()
    {
        return new Dimension(_sidePixels, _sidePixels);
    }
    
    @Override
    public Dimension getMinimumSize()
    {
        return new Dimension(_sidePixels, _sidePixels);
    }
}
