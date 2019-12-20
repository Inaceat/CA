package Robot.Hardware;

import java.util.LinkedList;

public class Bus
{
    private LinkedList<String> _data;


    public Bus()
    {
        _data = new LinkedList<>();
    }

    public String Get()
    {
        if (IsEmpty())
            return null;

        return _data.getFirst();
    }

    private boolean IsEmpty()
    {
        return _data.isEmpty();
    }

    public void Put(String data)
    {
        _data.addLast(data);
    }
}
