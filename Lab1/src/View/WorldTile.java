package View;

import javax.swing.*;
import javax.swing.plaf.basic.BasicBorders;
import java.awt.*;

public class WorldTile extends JComponent
{
    static int SideLength = 50;
    
    private Color _color;
    
    WorldTile(Color color)
    {
        _color = color;
        setBorder(new BasicBorders.FieldBorder(Color.black, Color.black, Color.black, Color.black));
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
    
    @Override
    protected void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        g.setColor(_color);
        g.fillRect(0,0, g.getClipBounds().width, g.getClipBounds().height);
    }
}
