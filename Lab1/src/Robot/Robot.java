package Robot;

import Events.Event;
import Events.EventHandler;
import Robot.Actions.ActionType;
import Robot.Actions.RobotAction;
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



    public Robot(World world)
    {
    }


    private Boolean SetProgram(String program)
    {
        return !program.contains("X");
    }

    private void Execute()
    {
        _actionDoneEvent.Fire(new RobotAction(ActionType.Move, "1,1"));

        _actionDoneEvent.Fire(new RobotAction(ActionType.TurnLeft, ""));

        _actionDoneEvent.Fire(new RobotAction(ActionType.PlaceMarker, "1,1"));
    }
}
