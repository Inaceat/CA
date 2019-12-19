package Robot.Actions;

import Robot.Robot;

public enum ActionType
{
    Move,//"x,y" of destination
    TurnLeft,
    TurnRight,
    PickUpMarker,//"x,y" of current tile
    PlaceMarker//"x,y" of current tile
}
