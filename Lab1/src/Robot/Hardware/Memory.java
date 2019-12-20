package Robot.Hardware;

public class Memory
{
    private int _size;

    private char[] _data;


    public Memory(int size)
    {
        _size = size;
        _data = new char[_size];

        Reset();
    }


    public int GetSize()
    {
        return _size;
    }


    public char GetByte(int address)
    {
        return _data[address];
    }

    public void SetByte(int address, char value)
    {
        _data[address] = value;
    }

    public void Reset()
    {
        for (int i = 0; i < _size; i++)
        {
            _data[i] = 0;
        }
    }
}
