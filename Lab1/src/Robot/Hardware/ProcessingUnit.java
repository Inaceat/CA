package Robot.Hardware;

import java.util.HashSet;
import java.util.List;

public class ProcessingUnit
{
    HashSet<String> _commandSet;

    public ProcessingUnit()
    {
        _commandSet = new HashSet<>();
        _commandSet.add("m");
        _commandSet.add("r");
        _commandSet.add("l");
    }

    public void ConnectController(ControlUnit controller)
    {

    }

    public HashSet<String> CommandSet()
    {
        return _commandSet;
    }
}
