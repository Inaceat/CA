import Robot.Robot;
import View.RobotMainWindow;
import World.World;

public class Main
{
    public static void main(String[] cmdArgs)
    {
        int[][] walls = { {2, 4}, {6, 8} };
        World world = new World(walls);


        var robotMainWindow = new RobotMainWindow("PainBot", world);
        robotMainWindow.setSize(800,600);

        var robot = new Robot(world);

        robot.AddActionHandler(robotMainWindow.OnRobotAction);
        robot.AddErrorHandler(robotMainWindow.OnRobotError);

        robotMainWindow.AddRobotStartPressedHandler(robot.OnExecutionRequest);

        robotMainWindow.Show();
    }
}
