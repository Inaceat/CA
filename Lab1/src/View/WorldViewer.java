package View;

import javax.swing.*;
import java.awt.*;

class WorldViewer
        extends JPanel
{
    private RobotViewer _robotView;
    
    private FieldTileViewer[][] _fieldTiles;
    
    
    private int sideLengthInTiles;
    private int _sideLengthInPixels;
    
    WorldViewer(int size)
    {
        super(true);
        
        setLayout(null);
        
        _fieldTiles = new FieldTileViewer[size][size];
    
        sideLengthInTiles = size;
        _sideLengthInPixels = size * FieldTileViewer.SideLength;
    
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                _fieldTiles[i][j] = new FieldTileViewer(Color.white);//new Color((int)(Math.random() * 0x1000000)));
    
                _fieldTiles[i][j].setBounds(i * FieldTileViewer.SideLength, j * FieldTileViewer.SideLength, FieldTileViewer.SideLength, FieldTileViewer.SideLength);
                
                add(_fieldTiles[i][j]);
            }
        }
    
        _robotView = new RobotViewer();
        
        add(_robotView, 0);
    
        MoveRobotToTile(0,0);
    }
    
    
    void MoveRobotToTile(int x, int y)
    {
        _robotView.setBounds(x * FieldTileViewer.SideLength, y * FieldTileViewer.SideLength, RobotViewer.SideLength, RobotViewer.SideLength);
    }
    
    void TurnRobotRight()
    {
        _robotView.TurnRight();
    }
    
    void TurnRobotLeft()
    {
        _robotView.TurnLeft();
    }
    
    
    void SetTileColor(int x, int y, Color color)
    {
        _fieldTiles[x][y].SetColor(color);
    }
    
    
    @Override
    public Dimension getPreferredSize()
    {
        return new Dimension(_sideLengthInPixels, _sideLengthInPixels);
    }
    
    @Override
    public Dimension getMaximumSize()
    {
        return new Dimension(_sideLengthInPixels, _sideLengthInPixels);
    }
    
    @Override
    public Dimension getMinimumSize()
    {
        return new Dimension(_sideLengthInPixels, _sideLengthInPixels);
    }
}
