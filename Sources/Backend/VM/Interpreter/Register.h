#pragma once
#include <cstdint>


namespace JSBackend::Interpreter {
    class Interpreter;

    class Register {
    public:
        Register(Interpreter* interpreter, uint16_t index, uint64_t value = 0)
            : m_interpreter(interpreter)
            , m_value(value)
            , m_index(index)
        {
        }

        static Register* Create(Interpreter* interpreter,uint16_t index)
        {
            return new Register(interpreter,index);
        }

        virtual ~Register() = default;

        uint16_t getIndex() const
        {
            return m_index;
        }

        void write64(uint64_t newValue)
        {
            m_value = newValue;
        }

        void write32(uint32_t newValue)
        {
            m_value = (m_value & 0xffffffff00000000ULL) | newValue;
        }

        void write16(uint16_t newValue)
        {
            m_value = (m_value & 0xffffffffffff0000ULL) | newValue;
        }

        void write8(uint8_t newValue)
        {
            m_value = (m_value & 0xffffffffffffff00ULL) | newValue;
        }

        uint64_t read64() const
        {
            return m_value;
        }

        uint32_t read32() const
        {
            return static_cast<uint32_t>(m_value & 0xffffffffULL);
        }

        uint16_t read16() const
        {
            return static_cast<uint16_t>(m_value & 0xffffULL);
        }

        uint8_t read8() const
        {
            return static_cast<uint8_t>(m_value & 0xffULL);
        }

    protected:
        Interpreter* m_interpreter;
        uint64_t m_value;
    private:
        uint16_t m_index;
    };

    class ProgramCounter {
    public:
        ProgramCounter(Interpreter* interpreter, uint64_t offset = 0)
            : m_interpreter(interpreter)
            , m_offset(offset)
        {
        }

        uint64_t getOffset() const
        {
            return m_offset;
        }

        void setOffset(uint32_t newOffset)
        {
            m_offset = newOffset;
        }
    private:
        Interpreter* m_interpreter;
        uint64_t m_offset;
    };

}
