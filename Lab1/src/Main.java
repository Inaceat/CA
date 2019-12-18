import Robot.Robot;
import View.RobotMainWindow;

public class Main
{
    public static void main(String[] cmdArgs)
    {
        var robotMainWindow = new RobotMainWindow("PainBot");
        robotMainWindow.setSize(800,600);

        var robot = new Robot();

        robot.AddActionHandler(robotMainWindow.OnRobotAction);
        robot.AddErrorHandler(robotMainWindow.OnRobotError);

        robotMainWindow.AddRobotStartPressedHandler(robot.OnExecutionRequest);

        robotMainWindow.Show();
    }
}
