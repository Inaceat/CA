package View;

import Events.Event;
import Events.EventHandler;

import Robot.Actions.RobotAction;

import World.World;

import javax.swing.*;
import java.awt.*;
import java.util.Timer;
import java.util.TimerTask;

public class RobotMainWindow
        extends JFrame
{
    private JPanel _root;

    private WorldViewer _wordViewer;
    private JTextArea   _text;
    private JLabel      _markersCountText;
    private JLabel      _errorText;

    private Color _emptyTileColor  = Color.WHITE;
    private Color _markedTileColor = Color.GREEN;
    private Color _wallTileColor   = Color.RED;


    public EventHandler<RobotAction> OnRobotAction = new EventHandler<>(
            action ->
            {
                String[] coordinateStrings;

                switch (action.Type())
                {
                    case Move:
                        coordinateStrings = action.Data().split(",");
                        _wordViewer.MoveRobotToTile(Integer.parseInt(coordinateStrings[0]),
                                                    Integer.parseInt(coordinateStrings[1]));
                        break;

                    case TurnLeft:
                        _wordViewer.TurnRobotLeft();
                        break;

                    case TurnRight:
                        _wordViewer.TurnRobotRight();
                        break;

                    case PickUpMarker:
                        coordinateStrings = action.Data().split(",");
                        _wordViewer.SetTileColor(Integer.parseInt(coordinateStrings[0]),
                                                 Integer.parseInt(coordinateStrings[1]),
                                                 _emptyTileColor);

                        _markersCountText.setText("Markers: " + coordinateStrings[2]);
                        break;

                    case PlaceMarker:
                        coordinateStrings = action.Data().split(",");
                        _wordViewer.SetTileColor(Integer.parseInt(coordinateStrings[0]),
                                                 Integer.parseInt(coordinateStrings[1]),
                                                 _markedTileColor);

                        _markersCountText.setText("Markers: " + coordinateStrings[2]);
                        break;
                }
            });

    public EventHandler<String> OnRobotError = new EventHandler<>(
            errorMessage ->
                    _errorText.setText(errorMessage));



    private Event<String> _robotStartPressed = new Event<>();
    public void AddRobotStartPressedHandler(EventHandler<String> handler)
    {
        _robotStartPressed.AddListener(handler);
    }


    public RobotMainWindow(String caption, World world)
    {
        super(caption);
        
        
        _root = new JPanel(new FlowLayout(FlowLayout.RIGHT), true);


        _text = new JTextArea();
        _text.setLineWrap(true);
        _root.add(_text);


        _wordViewer = new WorldViewer(10);
        for (int[] coordinates : world.GetWallsCoordinates())
        {
            _wordViewer.SetTileColor(coordinates[0], coordinates[1], _wallTileColor);
        }
        for (int[] coordinates : world.GetMarkersCoordinates())
        {
            _wordViewer.SetTileColor(coordinates[0], coordinates[1], _markedTileColor);
        }
        _root.add(_wordViewer);


        _errorText = new JLabel("");
        _root.add(_errorText);

        var button = new JButton("Execute");
        button.addActionListener(e -> {
            _errorText.setText("");
    
            TimerTask s = new TimerTask()
            {
                @Override
                public void run()
                {
                    _robotStartPressed.Fire(_text.getText());
                }
            };
            
            Timer x = new Timer();
            x.schedule(s, 0);
            
        });
        _root.add(button);


        _markersCountText = new JLabel("Markers: ?");
        _root.add(_markersCountText);


        setContentPane(_root);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    }

    public void Show()
    {
        setVisible(true);
    }
}