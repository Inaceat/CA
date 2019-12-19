package Robot.Actions;

import Robot.Actions.ActionType;
import Robot.Robot;

public class RobotAction
{
    private ActionType _type;
    private String     _actionData;

    public RobotAction(ActionType type, String actionData)
    {
        _type = type;
        _actionData = actionData;
    }

    public ActionType Type()
    {
        return _type;
    }

    public String Data()
    {
        return _actionData;
    }
}
