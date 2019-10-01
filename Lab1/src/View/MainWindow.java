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
        
        setContentPane(_root);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        setVisible(true);
    }


    public static void main(String[] args)
    {
        MainWindow mainWindow = new MainWindow("PainBot");
        
        mainWindow.setSize(800,600);
    
        //TODO temp, for debug purposes
        while(true)
        {
            try
            {
                Thread.sleep(1000);
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
            
            mainWindow._wordViewer.SetTileColor((int)(Math.random()*10), (int)(Math.random()*10), new Color((int)(Math.random() * 0x1000000)));
        }
    }
}