--Tests TypedEventConnection.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TypedEventConnection = require(ReplicatedStorage:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("TypedEventConnection"))

return function()
    describe("A TypedEventConnection", function()
        local TestTypedEventConnection = nil
        local DisconnectedEventLastCall: any? = nil
        local Fired = false
        beforeEach(function()
            TestTypedEventConnection = TypedEventConnection.new({
                Disconnected = function(_, Connection)
                    DisconnectedEventLastCall = Connection
                end,
            }, function()
                Fired = true
            end)
        end)

        afterEach(function()
            DisconnectedEventLastCall = nil
            Fired = false
        end)

        it("should fire events.", function()
            TestTypedEventConnection:Fire()
            expect(Fired).to.equal(true)
        end)

        it("should not fire disconnected events.", function()
            TestTypedEventConnection.Connected = false
            TestTypedEventConnection:Fire()
            expect(Fired).to.equal(false)
        end)

        it("should disconnect connections.", function()
            TestTypedEventConnection:Disconnect()
            expect(TestTypedEventConnection.Connected).to.equal(false)
            expect(DisconnectedEventLastCall).to.equal(TestTypedEventConnection)
        end)

        it("should destroy connections.", function()
            TestTypedEventConnection:Destroy()
            expect(TestTypedEventConnection.Connected).to.equal(false)
            expect(DisconnectedEventLastCall).to.equal(TestTypedEventConnection)
        end)

        it("should not disconnect disconnected events.", function()
            TestTypedEventConnection.Connected = false
            TestTypedEventConnection:Disconnect()
            expect(DisconnectedEventLastCall).to.equal(nil)
        end)
    end)
end