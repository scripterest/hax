local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Delta Executor UI",
   LoadingTitle = "Загрузка меню...",
   LoadingSubtitle = "от ВашеИмя",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DeltaUiConfig",
      FileName = "BigHub"
   },
   KeySystem = false -- Вы можете включить проверку ключа (true/false)
})
local MainTab = Window:CreateTab("Главная", 4483362458) -- Число в конце — это ID иконки
local PlayerTab = Window:CreateTab("Игрок", 4483362458)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local telekinesisEnabled = false
local telekinesisConnection = nil

-- Настройки телекинеза
local MAX_DISTANCE = 50 -- Радиус захвата предметов (в шпильках/студах)
local HOLD_DISTANCE = 7 -- На каком расстоянии ПЕРЕД игроком держать предметы

local TelekinesisToggle = PlayerTab:CreateToggle({
   Name = "Телекинез (Захват предметов)",
   CurrentValue = false,
   Flag = "TelekinesisToggle", 
   Callback = function(Value)
      telekinesisEnabled = Value
      
      -- Если включили и соединения еще нет
      if telekinesisEnabled then
         telekinesisConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            -- Вычисляем целевую точку (впереди игрока на HOLD_DISTANCE)
            local targetPosition = hrp.Position + (hrp.CFrame.LookVector * HOLD_DISTANCE)
            
            -- Ищем незакрепленные детали в рабочей области (Workspace)
            for _, part in ipairs(workspace:GetDescendants()) do
               if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) then
                  -- Проверяем расстояние от игрока до детали
                  local distance = (hrp.Position - part.Position).Magnitude
                  
                  if distance <= MAX_DISTANCE then
                     -- Отключаем коллизию с игроком, чтобы детали не толкали вас и не баговали
                     part.CanCollide = false 
                     
                     -- Направляем деталь к целевой точке (плавное следование)
                     local direction = (targetPosition - part.Position)
                     part.Velocity = direction * 7 -- Множитель скорости (можно увеличить)
                     
                     -- Дополнительно обнуляем вращение, чтобы предметы не крутились хаотично
                     part.RotVelocity = Vector3.new(0, 0, 0)
                  end
               end
            end
         end)
      else
         -- Если выключили, обрываем постоянный цикл следования
         if telekinesisConnection then
            telekinesisConnection:Disconnect()
            telekinesisConnection = nil
         end
         
         -- Возвращаем коллизию окружающим предметам обратно (опционально)
         local character = LocalPlayer.Character
         for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and (character and not part:IsDescendantOf(character)) then
               part.CanCollide = true
            end
         end
      end
   end,
})