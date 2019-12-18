package View;

import Events.Event;
import Events.EventHandler;

import javax.swing.*;
import java.awt.*;

public class RobotMainWindow
        extends JFrame
{
    private JPanel _root;

    private WorldViewer _wordViewer;
    private JTextArea _text;



    public EventHandler<String> OnRobotAction = new EventHandler<String>(
            args ->
            {
                _wordViewer.SetTileColor((int)(Math.random()*10), (int)(Math.random()*10), new Color((int)(Math.random() * 0x1000000)));
                System.out.println("Action \"" + args + "\"");
            });

    public EventHandler<String> OnRobotError = new EventHandler<String>(
            args ->
            {
                System.out.println("Error \"" + args + "\"");
            });



    private Event<String> _robotStartPressed = new Event<String>();
    public void AddRobotStartPressedHandler(EventHandler<String> handler)
    {
        _robotStartPressed.AddListener(handler);
    }


    public RobotMainWindow(String caption)
    {
        super(caption);
        
        
        _root = new JPanel(new FlowLayout(FlowLayout.RIGHT), true);


        _text = new JTextArea();
        _text.setSize(150, 150);

        _root.add(_text);


        _wordViewer = new WorldViewer(10);
        _root.add(_wordViewer);


        var button = new JButton("Execute");
        button.addActionListener(e -> _robotStartPressed.Fire("FEUER!"));
        _root.add(button);


        setContentPane(_root);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    }

    public void Show()
    {
        setVisible(true);
    }
}