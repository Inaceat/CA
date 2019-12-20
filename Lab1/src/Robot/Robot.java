package Robot;

import Events.*;
import Robot.Actions.*;
import Robot.Hardware.*;

import World.World;


public class Robot
{
    private ProcessingUnit _cpu;
    private Memory         _memory;
    private ControlUnit    _controller;
    private Chassis        _chassis;


    public void AddActionHandler(EventHandler<RobotAction> handler)
    {
        _controller.AddActionHandler(handler);
    }
    public void AddErrorHandler(EventHandler<String> handler)
    {
        _controller.AddErrorHandler(handler);
    }


    public EventHandler<String> OnExecutionRequest = new EventHandler<>(
            programText ->
            {
                if (_controller.LoadProgram(programText))
                    _controller.StartRobot();
            });


    public Robot(World world)
    {
        _chassis = new Chassis(world, 0, 0, Chassis.LookDirection.North);

        _memory = new Memory(4096);
        _cpu = new ProcessingUnit();

        _controller = new ControlUnit(_cpu, _memory, _chassis);

        _cpu.ConnectController(_controller);//...
    }
}
