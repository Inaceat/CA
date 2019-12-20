package Robot.Hardware;

import java.util.HashMap;
import java.util.HashSet;

public class ProcessingUnit
{
    private HashSet<Character> _commandSet;
    private HashMap<Character, Runnable> _instructions;

    private ControlUnit _controlUnit;

    private int _nextInstruction;


    public ProcessingUnit()
    {
        _commandSet = new HashSet<>();
        _commandSet.add('m');
        _commandSet.add('r');
        _commandSet.add('l');
        _commandSet.add('p');
        _commandSet.add('t');

        _instructions = new HashMap<>();
        _instructions.put('m', this::MoveInstruction);
        _instructions.put('r', this::TurnRightInstruction);
        _instructions.put('l', this::TurnLeftInstruction);
        _instructions.put('p', this::PlaceMarkerInstruction);
        _instructions.put('t', this::TakeMarkerInstruction);
    }


    public void ConnectController(ControlUnit controller)
    {
        _controlUnit = controller;
    }


    public HashSet<Character> CommandSet()
    {
        return _commandSet;
    }


    public void Reset()
    {
        _nextInstruction = 0;
    }

    public boolean CanExecute()
    {
        return '0' != _controlUnit.GetMemoryByte(_nextInstruction);
    }

    public void ExecuteNextCommand()
    {
        char instruction = _controlUnit.GetMemoryByte(_nextInstruction);

        _instructions.get(instruction).run();

        ++_nextInstruction;
    }


    private void MoveInstruction()
    {
        _controlUnit.MoveChassisForward();
    }

    private void TurnLeftInstruction()
    {
        _controlUnit.TurnChassisLeft();
    }

    private void TurnRightInstruction()
    {
        _controlUnit.TurnChassisRight();
    }

    private void TakeMarkerInstruction()
    {
        _controlUnit.PickMarker();
    }

    private void PlaceMarkerInstruction()
    {
        _controlUnit.PlaceMarker();
    }
}
