package View;

import javax.swing.*;
import java.awt.*;

public class MainWindow extends JFrame
{
    private JPanel rootPanel;

    private MainWindow(String caption)
    {
        super(caption);

        rootPanel.add(new WorldTile());
        
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