#pragma once
namespace JSBackend::GarbageCollector {
    class JSCell;

    class Visitor {
    public:
        virtual void visit(JSCell* ptr) = 0;
        virtual ~Visitor() = default;
    };

    class Tracer : public Visitor {
    public:
        void visit(JSCell* ptr) override {

        }
    };

    class Sweeper : public Visitor {
    public:
        void visit(JSCell* ptr) override {

        }
    };

    class Finalizer : public Visitor {
    public:
        void visit(JSCell* ptr) override {
        }
    };
}
