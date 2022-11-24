--[[
TheNexusAvenger

Tests for the NexusEvent class.
--]]
--!strict

local NexusEvent = require(game.ReplicatedStorage.NexusInstance.Event.NexusEvent)

return function()
    local TestEvent: NexusEvent.NexusEvent<...any> = nil
    beforeEach(function()
        TestEvent = NexusEvent.new()
    end)
    afterEach(function()
        TestEvent:Disconnect()
    end)

    describe("An event", function()
        it("should connect callbacks.", function()
            local TimesInvoked = 0
            for _ = 1, 3 do
                TestEvent:Connect(function()
                    TimesInvoked += 1
                end)
            end

            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(3)
            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(6)
        end)

        it("should disconnect invidual connections.", function()
            local TimesInvoked = 0
            local Connection1 = TestEvent:Connect(function() TimesInvoked += 1 end)
            local Connection2 = TestEvent:Connect(function() TimesInvoked += 1 end)
            local Connection3 = TestEvent:Connect(function() TimesInvoked += 1 end)

            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(3)

            Connection1:Disconnect()
            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(5)

            Connection2:Disconnect()
            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(6)

            Connection3:Disconnect()
            TestEvent:Fire()
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

            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(3)

            TestEvent:Disconnect()
            TestEvent:Fire()
            task.wait()
            expect(TimesInvoked).to.equal(3)
        end)

        it("should fire with multiple parameters.", function()
            local InvokeA, InvokeB, InvokeC = nil, nil, nil
            TestEvent:Connect(function(A, B, C)
                InvokeA = A
                InvokeB = B
                InvokeC = C
            end)

            TestEvent:Fire(1, 2, 3)
            task.wait()
            expect(InvokeA).to.equal(1)
            expect(InvokeB).to.equal(2)
            expect(InvokeC).to.equal(3)
        end)

        it("should fire with nil parameters.", function()
            local InvokeA, InvokeB, InvokeC = nil, nil, nil
            TestEvent:Connect(function(A, B, C)
                InvokeA = A
                InvokeB = B
                InvokeC = C
            end)

            TestEvent:Fire(1, nil, 3)
            task.wait()
            expect(InvokeA).to.equal(1)
            expect(InvokeB).to.equal(nil)
            expect(InvokeC).to.equal(3)
        end)

        it("should fire multiple events in order.", function()
            local Invokes = {}
            TestEvent:Connect(function(Invoke)
                table.insert(Invokes, Invoke)
            end)

            for i = 1, 10 do
                TestEvent:Fire(i)
            end
            task.wait()
            for i = 1, 10 do
                expect(Invokes[i]).to.equal(i)
            end
        end)

        it("should fire unmodified tables", function()
            local InvokeA, InvokeB = nil, nil
            local TableA, TableB = {1,2,3}, {1,2,3}
            TestEvent:Connect(function(A, B, C)
                InvokeA = A
                InvokeB = B
            end)

            TestEvent:Fire(TableA, TableB)
            task.wait()
            expect(InvokeA == TableA).to.equal(true)
            expect(InvokeB == TableB).to.equal(true)
        end)

        it("should wait for events to be fired.", function()
            task.delay(0.1, function()
                TestEvent:Fire(1, 2, 3)
            end)

            local InvokeA, InvokeB, InvokeC = TestEvent:Wait()
            expect(InvokeA).to.equal(1)
            expect(InvokeB).to.equal(2)
            expect(InvokeC).to.equal(3)
        end)
    end)
end