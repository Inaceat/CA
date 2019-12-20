package Robot.Actions;

import Robot.Robot;

public enum ActionType
{
    Move,//"x,y" of destination
    TurnLeft,
    TurnRight,
    PickUpMarker,//"x,y,c": coords of current tile, markers left in robot
    PlaceMarker//"x,y,c": coords of current tile, markers left in robot
}
