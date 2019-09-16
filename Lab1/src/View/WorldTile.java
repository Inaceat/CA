package View;

import javax.swing.*;
import java.awt.*;

public class WorldTile extends JComponent
{
    private int _width;
    private int _height;
    
    WorldTile()
    {
        _width = 50;
        _height = 50;
    }

    @Override
    protected void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        g.setColor(Color.GREEN);
        g.fillRect(0,0, _width, _height);
    }
}
