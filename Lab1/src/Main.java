import Robot.Robot;
import View.RobotMainWindow;
import World.World;

public class Main
{
    public static void main(String[] cmdArgs)
    {
        int sizeX = 10;
        int sizeY = 10;
        int[][] walls = { {0, 3}, {0, 6},
                          {1, 1}, {1, 2}, {1, 3}, {1, 5}, {1, 6}, {1, 8},
                          {2, 6}, {2, 8},
                          {3, 0}, {3, 1}, {3, 2}, {3, 4}, {3, 8}, {3, 9},
                          {4, 1}, {4, 6},
                          {5, 3}, {5, 8},
                          {6, 0}, {6, 1}, {6, 5}, {6, 7}, {6, 8}, {6, 9},
                          {7, 1}, {7, 3},
                          {8, 1}, {8, 3}, {8, 4}, {8, 6}, {8, 7}, {8, 8},
                          {9, 3}, {9, 6}};
        
        int[][] markers = { {0, 0}, {2, 0}, {2, 2},
                            {9, 0}, {9, 2}, {7, 2},
                            {9, 9}, {7, 9}, {7, 7},
                            {0, 9}, {0, 7}, {2, 7}};

        World world = new World(sizeX, sizeY, walls, markers);


        var robotMainWindow = new RobotMainWindow("PainBot", world);
        robotMainWindow.setSize(800,600);

        var robot = new Robot(world);

        robot.AddActionHandler(robotMainWindow.OnRobotAction);
        robot.AddErrorHandler(robotMainWindow.OnRobotError);

        robotMainWindow.AddRobotStartPressedHandler(robot.OnExecutionRequest);

        robotMainWindow.Show();
    }
}
