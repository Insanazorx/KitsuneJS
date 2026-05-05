#pragma once
#include "Cell.h"
namespace js::GarbageCollector {
    class Cell;

    class Visitor {
    public:
        virtual void visit(Cell* ptr) = 0;
        virtual ~Visitor() = default;
    };

    class Tracer : public Visitor {
    public:
        void visit(Cell* ptr) override {

        }
    };

    class Sweeper : public Visitor {
    public:
        void visit(Cell* ptr) override {

        }
    };

    class Finalizer : public Visitor {
    public:
        void visit(Cell* ptr) override {
        }
    };
}