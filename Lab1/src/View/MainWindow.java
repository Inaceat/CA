package View;

import javax.swing.*;
import javax.swing.plaf.basic.BasicBorders;
import java.awt.*;

public class MainWindow extends JFrame
{
    private JPanel _root;
    
    private WorldField _wordField;

    private MainWindow(String caption)
    {
        super(caption);
        
        
        _root = new JPanel(new FlowLayout(FlowLayout.RIGHT), true);
        
        
        _wordField = new WorldField(10);
        _root.add(_wordField);
    
        setContentPane(_root);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
    }


    public static void main(String[] args)
    {
        MainWindow mainWindow = new MainWindow("PainBot");
        
        mainWindow.setSize(800,600);
    }
}