--[[ FexMaxHub - Candy & Chocolate God Mode & Velocidad ]]

pcall(function() 
   if hookmetamethod and getnamecallmethod then 
      local oldNamecall 
      oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...) 
         if tostring(getnamecallmethod()):lower() == "kick" then 
            return nil 
         end 
         return oldNamecall(self, ...) 
      end)) 
   end 
end)

local Rayfield 
local success = pcall(function() 
   Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

if not success or not Rayfield then 
   Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLTD/Rayfield/main/source.lua'))() 
end

local Window = Rayfield:CreateWindow({ 
   Name = "FexMaxHub", 
   LoadingTitle = "FexMaxHub", 
   LoadingSubtitle = "Candy & Chocolate", 
   ConfigurationSaving = { Enabled = false }, 
   Discord = { Enabled = false }, 
   KeySystem = false 
})

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local LocalPlayer = Players.LocalPlayer

local GodMode = false 
local CurrentSpeed = 50 
local SpeedActive = false 
local SpeedEndTime = 0 
local SPEED_DURATION = 86400

local LastSafeCFrame = nil 
local LastSafeTime = 0 
local Restoring = false

local MainTab = Window:CreateTab("Principal", 0)

MainTab:CreateSection("God Mode")

MainTab:CreateToggle({ 
   Name = "God Mode (No mueres)", 
   CurrentValue = false, 
   Flag = "GodMode", 
   Callback = function(Value) 
      GodMode = Value 
      if Value then 
         local char = LocalPlayer.Character 
         if char and char:FindFirstChild("HumanoidRootPart") then 
            LastSafeCFrame = char.HumanoidRootPart.CFrame 
         end 
         Rayfield:Notify({Title = "God Mode", Content = "ON", Duration = 4}) 
      else 
         Rayfield:Notify({Title = "God Mode", Content = "OFF", Duration = 3}) 
      end 
   end, 
})

RunService.Heartbeat:Connect(function() 
   local character = LocalPlayer.Character 
   if not character then return end
   
   local hrp = character:FindFirstChild("HumanoidRootPart") 
   local humanoid = character:FindFirstChildOfClass("Humanoid") 
   if not hrp or not humanoid then return end

   if GodMode then 
      if humanoid.Health > 0 and humanoid.Health < 1e9 then 
         humanoid.MaxHealth = 1e9 
         humanoid.Health = 1e9 
      end
      
      humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
      humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
      humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

      if not Restoring and hrp.AssemblyLinearVelocity.Y > -80 then
         if (os.clock() - LastSafeTime) > 0.5 then
            LastSafeCFrame = hrp.CFrame
            LastSafeTime = os.clock()
         end
      end
      
      local maxAllowedDist = math.max(180, CurrentSpeed * 1.8)
      
      if LastSafeCFrame and not Restoring then
         local dist = (hrp.Position - LastSafeCFrame.Position).Magnitude
         if dist > maxAllowedDist then
            Restoring = true
            hrp.CFrame = LastSafeCFrame + Vector3.new(0, 3, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.delay(0.4, function() Restoring = false end)
         end
      end
   end 
end)

MainTab:CreateSection("Velocidad")

MainTab:CreateSlider({ 
   Name = "Velocidad (WalkSpeed)", 
   Range = {16, 300}, 
   Increment = 1, 
   Suffix = "", 
   CurrentValue = 50, 
   Flag = "WalkSpeed", 
   Callback = function(Value) 
      CurrentSpeed = Value 
      if SpeedActive then 
         local character = LocalPlayer.Character 
         if character then 
            local humanoid = character:FindFirstChildOfClass("Humanoid") 
            if humanoid then humanoid.WalkSpeed = Value end 
         end 
      end 
   end, 
})

MainTab:CreateButton({ 
   Name = "Activar Velocidad", 
   Callback = function() 
      SpeedActive = true 
      SpeedEndTime = os.clock() + SPEED_DURATION
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then
            humanoid.WalkSpeed = CurrentSpeed
            humanoid.PlatformStand = false
         end
      end
      Rayfield:Notify({Title = "Velocidad", Content = "Activada", Duration = 4})
   end, 
})

MainTab:CreateButton({ 
   Name = "Desactivar Velocidad", 
   Callback = function() 
      SpeedActive = false 
      SpeedEndTime = 0
      local character = LocalPlayer.Character
      if character then
         local humanoid = character:FindFirstChildOfClass("Humanoid")
         if humanoid then humanoid.WalkSpeed = 16 end
      end
      Rayfield:Notify({Title = "Velocidad", Content = "Desactivada", Duration = 3})
   end, 
})

RunService.Stepped:Connect(function() 
   if SpeedActive then 
      if os.clock() >= SpeedEndTime then 
         SpeedActive = false 
         local character = LocalPlayer.Character 
         if character and character:FindFirstChildOfClass("Humanoid") then 
            character.Humanoid.WalkSpeed = 16 
         end 
         Rayfield:Notify({Title = "Velocidad", Content = "Terminado", Duration = 5}) 
      else 
         local character = LocalPlayer.Character 
         if character then 
            local humanoid = character:FindFirstChildOfClass("Humanoid") 
            if humanoid and humanoid.WalkSpeed ~= CurrentSpeed then 
               humanoid.WalkSpeed = CurrentSpeed 
               if humanoid.PlatformStand then humanoid.PlatformStand = false end 
            end 
         end 
      end 
   end 
end)

LocalPlayer.CharacterAdded:Connect(function(character) 
   local humanoid = character:WaitForChild("Humanoid", 5) 
   local hrp = character:WaitForChild("HumanoidRootPart", 5) 
   if not humanoid or not hrp then return end
   task.wait(0.5)
   
   if GodMode then 
      humanoid.MaxHealth = 1e9 
      humanoid.Health = 1e9 
      if LastSafeCFrame then hrp.CFrame = LastSafeCFrame + Vector3.new(0, 4, 0) end 
   end
   
   if SpeedActive and os.clock() < SpeedEndTime then 
      humanoid.WalkSpeed = CurrentSpeed 
      humanoid.PlatformStand = false 
   end 
end)

Rayfield:Notify({Title = "FexMaxHub", Content = "Cargado ✓", Duration = 4})
