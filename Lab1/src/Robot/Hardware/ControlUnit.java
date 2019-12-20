package Robot.Hardware;

public class ControlUnit
{
    private Bus _cpuInput;
    private Bus _cpuOutput;

    private Bus _memoryInput;
    private Bus _memoryOutput;

    private Bus _chassisInput;
    private Bus _chassisOutput;


    private ProcessingUnit _cpu;
    private Memory         _memory;
    private Chassis        _chassis;

    public ControlUnit(ProcessingUnit cpu, Memory memory, Chassis chassis)
    {
        _cpu = cpu;
        _memory = memory;
        _chassis = chassis;
    }

    public boolean LoadProgram(String program)
    {
        if (program.length() > _memory.GetSize())
            return false;

        //If all symbols are valid
        for (int i = 0; i < program.length(); i++)
        {
            if (_cpu._commandSet.contains(Character.toString(program.charAt(i))))//meh..
            {
                _memory.SetByte(i, program.charAt(i));
            }
            else
            {
                _memory.Reset();
                return false;
            }
        }

        return true;
    }

    public void StartRobot()
    {

    }
}
