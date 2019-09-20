package View;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class MainWindow extends JFrame
{
    private JPanel _root;
    
    private WorldViewer _wordViewer;

    private MainWindow(String caption)
    {
        super(caption);
        
        
        _root = new JPanel(new FlowLayout(FlowLayout.RIGHT), true);
        
        
        _wordViewer = new WorldViewer(10);
        _root.add(_wordViewer);
        
        //TODO temp, for debug purposes
        var button = new JButton("Turn right");
        button.addActionListener(e -> _wordViewer.TurnRobotRight());
        _root.add(button);
    
        var button2 = new JButton("Paint smth");
        button2.addActionListener(e -> _wordViewer.SetTileColor((int)(Math.random()*10), (int)(Math.random()*10), new Color((int)(Math.random() * 0x1000000))));
        _root.add(button2);
        
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