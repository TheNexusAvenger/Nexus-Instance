--Tests TypedEvent.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TypedEvent = require(ReplicatedStorage:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("TypedEvent"))

return function()
    describe("A TypedEvent", function()
        local TestEvent = nil
        beforeEach(function()
            TestEvent = TypedEvent.new() :: TypedEvent.TypedEvent<string, string?, {[number]: string}>
        end)

        afterEach(function()
            TestEvent:Destroy()
        end)

        it("should connect callback with arguments.", function()
            local Calls = {}
            TestEvent:Connect(function(Argument1, Argument2, Argument3)
                table.insert(Calls, {Argument1, Argument2 :: any, Argument3 :: any})
            end)

            local Table1, Table2 = {}, {}
            TestEvent:Fire("Test1", "Test2", Table1)
            TestEvent:Fire("Test3", "Test4", Table2)
            task.wait()
            expect(Calls[1][1]).to.equal("Test1")
            expect(Calls[1][2]).to.equal("Test2")
            expect(Calls[1][3]).to.equal(Table1)
            expect(Calls[2][1]).to.equal("Test3")
            expect(Calls[2][2]).to.equal("Test4")
            expect(Calls[2][3]).to.equal(Table2)
            expect(Calls[3]).to.equal(nil)
        end)

        it("should connect multiple callbacks.", function()
            local TimesInvoked = 0
            for i = 1, 3 do
                TestEvent:Connect(function()
                    TimesInvoked += 1
                end)
            end

            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(3)
            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(6)
        end)

        it("should disconnect individual events.", function()
            local TimesInvoked = 0
            local Connection1 = TestEvent:Connect(function()
                TimesInvoked += 1
            end)
            local Connection2 = TestEvent:Connect(function()
                TimesInvoked += 1
            end)
            local Connection3 = TestEvent:Connect(function()
                TimesInvoked += 1
            end)

            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(3)

            Connection1:Disconnect()
            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(5)

            Connection2:Disconnect()
            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(6)

            Connection3:Disconnect()
            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(6)
        end)

        it("should disconnect all connections.", function()
            local TimesInvoked = 0
            for _ = 1, 3 do
                TestEvent:Connect(function()
                    TimesInvoked += 1
                end)
            end

            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(3)

            TestEvent:Destroy()
            TestEvent:Fire("Test1", "Test2", {})
            task.wait()
            expect(TimesInvoked).to.equal(3)
        end)

        it("should connect callback with nil arguments.", function()
            local Calls = {}
            TestEvent:Connect(function(Argument1, Argument2, Argument3)
                table.insert(Calls, {Argument1, Argument2 :: any, Argument3 :: any})
            end)

            local Table1, Table2 = {}, {}
            TestEvent:Fire("Test1", nil, Table1)
            TestEvent:Fire("Test3", nil, Table2)
            task.wait()
            expect(Calls[1][1]).to.equal("Test1")
            expect(Calls[1][2]).to.equal(nil)
            expect(Calls[1][3]).to.equal(Table1)
            expect(Calls[2][1]).to.equal("Test3")
            expect(Calls[2][2]).to.equal(nil)
            expect(Calls[2][3]).to.equal(Table2)
            expect(Calls[3]).to.equal(nil)
        end)

        it("should connect callback with arguments once.", function()
            local Calls = {}
            TestEvent:Once(function(Argument1, Argument2, Argument3)
                table.insert(Calls, {Argument1, Argument2 :: any, Argument3 :: any})
            end)

            local Table1, Table2 = {}, {}
            TestEvent:Fire("Test1", "Test2", Table1)
            TestEvent:Fire("Test3", "Test4", Table2)
            task.wait()
            expect(Calls[1][1]).to.equal("Test1")
            expect(Calls[1][2]).to.equal("Test2")
            expect(Calls[1][3]).to.equal(Table1)
            expect(Calls[2]).to.equal(nil)
        end)

        it("should wait for events to be fired.", function()
            task.defer(function()
                TestEvent:Fire("Test1", "Test2", {[2] = "Test3", [4] = "Test4"})
            end)

            local Argument1, Argument2, Argument3 = TestEvent:Wait()
            expect(Argument1).to.equal("Test1")
            expect(Argument2).to.equal("Test2")
            expect(Argument3[1]).to.equal(nil)
            expect(Argument3[2]).to.equal("Test3")
            expect(Argument3[3]).to.equal(nil)
            expect(Argument3[4]).to.equal("Test4")
            expect(Argument3[5]).to.equal(nil)
        end)

        it("should not fire events with no connections.", function()
            TestEvent:Fire("Test1", "Test2", {})
            local Index1, _ = next(TestEvent.LastArgumentsStrong)
            local Index2, _ = next(TestEvent.LastArguments)
            expect(Index1).to.equal(nil)
            expect(Index2).to.equal(nil)
        end)
    end)
end
