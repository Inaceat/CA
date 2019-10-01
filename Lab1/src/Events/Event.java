package Events;

import java.util.ArrayList;

public class Event<TFirstHandlerArgument>
{
    private ArrayList<EventHandler<TFirstHandlerArgument>> _handlers;
    
    public Event()
    {
        _handlers = new ArrayList<EventHandler<TFirstHandlerArgument>>();
    }
    
    public void AddListener(EventHandler<TFirstHandlerArgument> listener)
    {
        _handlers.add(listener);
    }
    
    public void RemoveListener(EventHandler<TFirstHandlerArgument> listener)
    {
        _handlers.remove(listener);
    }
    
    public void Fire(TFirstHandlerArgument argument)
    {
        for(var handler: _handlers)
            handler.Invoke(argument);
    }
}
