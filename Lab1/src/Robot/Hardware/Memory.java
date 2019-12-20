package Robot.Hardware;

public class Memory
{
    private int _size;

    private Character[] _data;


    public Memory(int size)
    {
        _size = size;
        _data = new Character[_size];

        Reset();
    }


    public int GetSize()
    {
        return _size;
    }


    public Character GetByte(int address)
    {
        return _data[address];
    }

    public void SetByte(int address, Character value)
    {
        _data[address] = value;
    }

    public void Reset()
    {
        for (int i = 0; i < _size; i++)
        {
            _data[i] = '0';
        }
    }
}
