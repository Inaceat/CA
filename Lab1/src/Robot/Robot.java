package Robot;

import Events.Event;
import Events.EventHandler;

public class Robot
{
    private Event<String> _actionDoneEvent = new Event<String>();
    public void AddActionHandler(EventHandler<String> handler)
    {
        _actionDoneEvent.AddListener(handler);
    }

    private Event<String> _errorHappenedEvent = new Event<String>();
    public void AddErrorHandler(EventHandler<String> handler)
    {
        _errorHappenedEvent.AddListener(handler);
    }


    public EventHandler<String> OnExecutionRequest = new EventHandler<String>(
            programText ->
            {
                SetProgram(programText);
                Execute();
            });



    private void SetProgram(String program)
    {
        _actionDoneEvent.Fire("Program set");
    }

    private void Execute()
    {
        _errorHappenedEvent.Fire("Error: no program");
    }
}
