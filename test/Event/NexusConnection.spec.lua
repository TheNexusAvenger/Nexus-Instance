--[[
TheNexusAvenger

Tests for the NexusConnection class.
--]]
--!strict

local NexusConnection = require(game.ReplicatedStorage.NexusInstance.Event.NexusConnection)

return function()
    local MockEvent = {Disconnected = function() end}
    describe("A connection", function()
        it("should be constructed correctly.", function()
            local Connection = NexusConnection.new(MockEvent, function() end)
            expect(Connection.ClassName).to.equal("NexusConnection")
            expect(Connection:IsA("NexusConnection")).to.equal(true)
            expect(Connection:IsA("NexusObject")).to.equal(true)
            expect(Connection.Connected).to.equal(true)
        end)

        it("should fire correctly.", function()
            local InvokeResult1, InvokeResult2, InvokeResult3 = nil, nil, nil
            NexusConnection.new(MockEvent, function(Result1: any, Result2: any, Result3: any)
                InvokeResult1 = Result1
                InvokeResult2 = Result2
                InvokeResult3 = Result3
            end):Fire(1, 2, 3)
            
            expect(InvokeResult1).to.equal(1)
            expect(InvokeResult2).to.equal(2)
            expect(InvokeResult3).to.equal(3)
        end)

        it("should disconnect correctly.", function()
            local InvokeResult1, InvokeResult2, InvokeResult3 = nil, nil, nil
            local Connection = NexusConnection.new(MockEvent, function(Result1: any, Result2: any, Result3: any)
                InvokeResult1 = Result1
                InvokeResult2 = Result2
                InvokeResult3 = Result3
            end)
            
            Connection:Fire(1, 2, 3)
            expect(InvokeResult1).to.equal(1)
            expect(InvokeResult2).to.equal(2)
            expect(InvokeResult3).to.equal(3)

            Connection:Disconnect()
            expect(Connection.Connected).to.equal(false)
            Connection:Fire(4, 5, 6)
            expect(InvokeResult1).to.equal(1)
            expect(InvokeResult2).to.equal(2)
            expect(InvokeResult3).to.equal(3)
        end)
    end)
end