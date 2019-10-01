import Events.Event;
import Events.EventHandler;

import java.util.function.Consumer;

//Subscriber
class DummyUser
{
    private EventHandler<DummyRobot.ShitHappenedEventArgs> ShitHappenedHandler = new EventHandler<>(
            (args ->
            {
                System.out.println(args.ShitDescription());
            }));
    
    private EventHandler<String> AnotherEventHandler = new EventHandler<String>(
            (String s) ->
            {
                var xx = "Another handler: ";
                System.out.println(xx + s);
            });
    
    public static void main(String[] args)
    {
        var robotBobot = new DummyRobot();
        var user       = new DummyUser();
        
        System.out.println("Hello Events");
        
        robotBobot.ShitHappenedEvent.AddListener(user.ShitHappenedHandler);
        robotBobot.Run();
        robotBobot.ShitHappenedEvent.RemoveListener(user.ShitHappenedHandler);
        
        System.out.println("After removing");
        robotBobot.Run();
        
        robotBobot.AnotherEvent.AddListener(user.AnotherEventHandler);
        robotBobot.Run();
    }
}

//Invoker
class DummyRobot
{
    public class ShitHappenedEventArgs
    {
        String _description;
        
        public ShitHappenedEventArgs(String shitDescription)
        {
            _description = shitDescription;
        }
        
        public String ShitDescription()
        {
            return _description;
        }
    }
    
    public Event<ShitHappenedEventArgs> ShitHappenedEvent = new Event<ShitHappenedEventArgs>();
    
    public Event<String> AnotherEvent = new Event<String>();
    
    
    public void Run()
    {
        ShitHappenedEvent.Fire(new ShitHappenedEventArgs("1"));
        
        ShitHappenedEvent.Fire(new ShitHappenedEventArgs("2"));
        
        ShitHappenedEvent.Fire(new ShitHappenedEventArgs("3"));
        
        AnotherEvent.Fire("Another");
    }
}
