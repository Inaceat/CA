package View;

import javax.swing.*;
import java.awt.*;

public class WorldTile extends JComponent
{
    WorldTile()
    {
    
    }

    @Override
    protected void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        g.setColor(Color.GREEN);
        g.fillRect(8,8,100,100);
    }
}
