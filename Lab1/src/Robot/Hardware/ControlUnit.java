package Robot.Hardware;

import Events.Event;
import Events.EventHandler;
import Robot.Actions.ActionType;
import Robot.Actions.RobotAction;

public class ControlUnit
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


    private ProcessingUnit _cpu;
    private Memory         _memory;
    private Chassis        _chassis;


    public ControlUnit(ProcessingUnit cpu, Memory memory, Chassis chassis)
    {
        _cpu = cpu;
        _memory = memory;
        _chassis = chassis;
    }

    public boolean LoadProgram(String program)
    {
        _memory.Reset();

        if (program.length() > _memory.GetSize())
        {
            _errorHappenedEvent.Fire("Not enough memory!");
            return false;
        }

        //If all symbols are valid
        for (int i = 0; i < program.length(); i++)
        {
            if (_cpu.CommandSet().contains(program.charAt(i)))
            {
                _memory.SetByte(i, program.charAt(i));
            }
            else
            {
                _memory.Reset();
                _errorHappenedEvent.Fire("Invalid program!");
                return false;
            }
        }

        return true;
    }

    public void StartRobot()
    {
        _cpu.Reset();

        while (_cpu.CanExecute())
        {
            _cpu.ExecuteNextCommand();
            //sleep
        }
    }

    private void ResetRobot()
    {
        _cpu.Reset();
        _memory.Reset();
    }

    public Character GetMemoryByte(int address)
    {
        return _memory.GetByte(address);
    }


    public void MoveChassisForward()
    {
        var moved = _chassis.MoveForward();

        if(moved)
        {
            StringBuilder data = new StringBuilder();
            data.append(_chassis.GetXCoordinate());
            data.append(',');
            data.append(_chassis.GetYCoordinate());

            _actionDoneEvent.Fire(new RobotAction(ActionType.Move, data.toString()));
        }
        else
        {
            _errorHappenedEvent.Fire("Can't move!");
            ResetRobot();
        }
    }

    public void TurnChassisLeft()
    {
        _chassis.TurnLeft();
        _actionDoneEvent.Fire(new RobotAction(ActionType.TurnLeft, ""));
    }

    public void TurnChassisRight()
    {
        _chassis.TurnRight();
        _actionDoneEvent.Fire(new RobotAction(ActionType.TurnRight, ""));
    }

    public void PlaceMarker()
    {
        var placed = _chassis.PlaceMarker();

        if(placed)
        {
            StringBuilder data = new StringBuilder();
            data.append(_chassis.GetXCoordinate());
            data.append(',');
            data.append(_chassis.GetYCoordinate());
            data.append(',');
            data.append(_chassis.GetMarkersCount());

            _actionDoneEvent.Fire(new RobotAction(ActionType.PlaceMarker, data.toString()));
        }
        else
        {
            _errorHappenedEvent.Fire("Can't place!");
            ResetRobot();
        }
    }

    public void PickMarker()
    {
        var picked = _chassis.RemoveMarker();

        if(picked)
        {
            StringBuilder data = new StringBuilder();
            data.append(_chassis.GetXCoordinate());
            data.append(',');
            data.append(_chassis.GetYCoordinate());
            data.append(',');
            data.append(_chassis.GetMarkersCount());

            _actionDoneEvent.Fire(new RobotAction(ActionType.PickUpMarker, data.toString()));
        }
        else
        {
            _errorHappenedEvent.Fire("Can't pick up marker!");
            ResetRobot();
        }
    }
}
