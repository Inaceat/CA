package View;

import javax.swing.*;
import javax.swing.plaf.basic.BasicBorders;
import java.awt.*;

public class MainWindow extends JFrame
{
    private JPanel rootPanel;

    private MainWindow(String caption)
    {
        super(caption);
    
        rootPanel.setLayout(new GridLayout(2,2));
        
        var tile1 = new WorldTile();
        tile1.setBorder(new BasicBorders.ButtonBorder(Color.RED, Color.RED, Color.RED, Color.RED));
        rootPanel.add(tile1);
    
        var tile2 = new WorldTile();
        tile2.setBorder(new BasicBorders.ButtonBorder(Color.BLUE, Color.BLUE, Color.BLUE, Color.BLUE));
        rootPanel.add(tile2);
    
        var tile3 = new WorldTile();
        tile3.setBorder(new BasicBorders.ButtonBorder(Color.GREEN, Color.GREEN, Color.GREEN, Color.GREEN));
        rootPanel.add(tile3);
    
        var tile4 = new WorldTile();
        tile4.setBorder(new BasicBorders.ButtonBorder(Color.YELLOW, Color.YELLOW, Color.YELLOW, Color.YELLOW));
        rootPanel.add(tile4);
        
        setContentPane(rootPanel);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
    }


    public static void main(String[] args)
    {
        MainWindow mainWindow = new MainWindow("PainBot");

        mainWindow.setSize(800,600);
    }
}