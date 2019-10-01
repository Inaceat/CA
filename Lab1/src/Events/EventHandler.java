package Events;

import java.util.function.BiConsumer;
import java.util.function.Consumer;

public class EventHandler<TFirstHandlerArgument>
{
    private Consumer<TFirstHandlerArgument> _handler;
    
    public EventHandler(Consumer<TFirstHandlerArgument> handler)
    {
        _handler = handler;
    }
    
    public void Invoke(TFirstHandlerArgument firstArgument)
    {
        _handler.accept(firstArgument);
    }
}

/*public class EventHandler<TFirstHandlerArgument, TSecondHandlerArgument>
{
    private BiConsumer<TFirstHandlerArgument, TSecondHandlerArgument> _handler;
    
    public EventHandler(BiConsumer<TFirstHandlerArgument, TSecondHandlerArgument> handler)
    {
        _handler = handler;
    }
    
    public void Invoke(TFirstHandlerArgument firstArgument, TSecondHandlerArgument secondHandlerArgument)
    {
        _handler.accept(firstArgument, secondHandlerArgument);
    }
}*/
