package Robot;

import Events.*;
import Robot.Actions.*;
import Robot.Hardware.*;

import World.World;


public class Robot
{
    private Event<RobotAction> _actionDoneEvent = new Event<>();
    public void AddActionHandler(EventHandler<RobotAction> handler)
    {
        _actionDoneEvent.AddListener(handler);
    }

    private Event<String> _errorHappenedEvent = new Event<>();
    public void AddErrorHandler(EventHandler<String> handler)
    {
        _errorHappenedEvent.AddListener(handler);
    }


    public EventHandler<String> OnExecutionRequest = new EventHandler<>(
            programText ->
            {
                if (programText.isEmpty())
                {
                    _errorHappenedEvent.Fire("Error: no program!");
                    return;
                }

                if (!SetProgram(programText))
                {
                    _errorHappenedEvent.Fire("Error: invalid program!");
                    return;
                }

                Execute();
            });

    
    
    private ProcessingUnit _cpu;
    private Memory         _memory;
    private ControlUnit    _controller;
    private Chassis        _chassis;
    

    public Robot(World world)
    {
        _chassis = new Chassis(world, 0, 0, Chassis.LookDirection.North);

        _memory = new Memory(4096);
        _cpu = new ProcessingUnit();

        _controller = new ControlUnit(_cpu, _memory, _chassis);

        _cpu.ConnectController(_controller);//...
    }


    private boolean SetProgram(String program)
    {
        return _controller.LoadProgram(program);
    }

    private void Execute()
    {
        _controller.StartRobot();

        //_actionDoneEvent.Fire(new RobotAction(ActionType.Move, "1,1"));
        //_actionDoneEvent.Fire(new RobotAction(ActionType.TurnLeft, ""));
        //_actionDoneEvent.Fire(new RobotAction(ActionType.PlaceMarker, "1,1"));
    }
}
