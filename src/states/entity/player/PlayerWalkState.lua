--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
-- for index, obj in ipairs(self.dungeon.currentRoom.objects) do
--     if self.entity:collides(obj) then
--         self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
--         do return end
--     end
-- end


--idk spend about 4 hours figuring why i pass this in player class or dungeon class and i didnt stores to be used in another states


PlayerWalkState = Class { __includes = EntityWalkState }

function PlayerWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('walk-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('walk-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('walk-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('walk-down')
    else
        self.entity:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    elseif love.keyboard.wasPressed('return') then
        if self.entity.direction == 'left' then
            hitboxWidth = 8
            hitboxHeight = 16
            hitboxX = self.entity.x - hitboxWidth
            hitboxY = self.entity.y + 2
            liftPot = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        elseif self.entity.direction == 'right' then
            hitboxWidth = 8
            hitboxHeight = 16
            hitboxX = self.entity.x + self.entity.width
            hitboxY = self.entity.y + 2
            liftPot = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        elseif self.entity.direction == 'up' then
            hitboxWidth = 16
            hitboxHeight = 8
            hitboxX = self.entity.x
            hitboxY = self.entity.y - hitboxHeight
            liftPot = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        else
            hitboxWidth = 16
            hitboxHeight = 8
            hitboxX = self.entity.x
            hitboxY = self.entity.y + self.entity.height
            liftPot = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        end

        -- separate hitbox for the player's sword; will only be active during this state
        -- liftPot = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        for index, obj in ipairs(self.dungeon.currentRoom.objects) do
            if obj:collides(liftPot) and obj.texture == 'tiles' and obj.state == 'full' and obj.projectile == false then
                self.entity.Pot = obj
                obj.solid = false
                self.entity:changeState('lift-pot')
            end
        end
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    -- if we bumped something when checking collision, check any object collisions
    if self.bumped then
        if self.entity.direction == 'left' then
            -- temporarily adjust position into the wall, since bumping pushes outward
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                end
            end

            -- readjust
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then
            -- temporarily adjust position
            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                end
            end

            -- readjust
            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then
            -- temporarily adjust position
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                end
            end

            -- readjust
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else
            -- temporarily adjust position
            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt

            -- check for colliding into doorway to transition
            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then
                    -- shift entity to center of door to avoid phasing through wall
                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                end
            end

            -- readjust
            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end
