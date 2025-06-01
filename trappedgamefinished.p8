pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- wall and actor collisions
-- by zep (modified with gravity and spikes)

actor = {} -- all actors
pl = nil -- store player reference globally
has_key = false -- global flag for key collection
debug_enabled = false -- toggle debug prints
killer_ball = nil -- global reference to killer ball
killer_ball2 = nil -- global reference to second killer ball
vertical_bat = nil -- global reference to vertical bat
vertical_bat2 = nil -- global reference to second vertical bat
vertical_bat3 = nil -- global reference to third vertical bat
vertical_bat4 = nil -- global reference to fourth vertical bat
vertical_bat5 = nil -- global reference to fifth vertical bat
vertical_bat6 = nil -- global reference to sixth vertical bat
vertical_bat7 = nil -- global reference to seventh vertical bat
death_count = 0 -- death counter
key_count = 0 -- counter for collected keys

function print_debug(msg)
    if debug_enabled then
        print(msg)
    end
end

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function make_actor(k, x, y)
    a={
        k = k,
        x = x,
        y = y,
        dx = 0,
        dy = 0,     
        frame = 0,
        t = 0,
        friction = 0.15,
        bounce  = 0.3,
        frames = 2,
        
        w = 0.4,
        h = 0.4,
        
        grounded = false,
        gravity = 0.03,
        max_fall_speed = 0.35,
        jump_force = -0.50,
        
        is_solid = true,
        
        anim_timer = 0,
        anim_speed = 120
    }
    
    print_debug("created actor with sprite: " .. k)
    add(actor,a)
    return a
end

function reset_game()
    print_debug("\n--- game reset ---")
    -- increment death counter
    death_count += 1
    print_debug("death count: " .. death_count)
    
    -- clear all actors and reset key flag
    actor = {}
    has_key = false
    key_count = 0 -- reset key counter on death
    print_debug("key count reset to 0")
    
    -- recreate all initial actors
    -- make player
    pl = make_actor(21,14.5,14)
    pl.frames=4
    
    -- door entity
    local door = make_actor(48,46.5,14.5)  -- adjusted position to x=46.5, y=14.5
    door.w = 0.5 
    door.h = 0.5
    door.is_solid = true
    door.is_door = true
    door.frames = 1  -- door doesn't animate
    
    -- bouncy ball (vertical only)
    local ball = make_actor(33,8.5,11)
    ball.dx = 0
    ball.dy = -0.1
    ball.friction = 0.02
    ball.bounce = 1
    
    -- first key (original spawn)
    local key1 = make_actor(35,11.5,1.5)
    key1.w=0.25 
    key1.h=0.25
    key1.is_solid = false
    key1.frames = 2
    key1.anim_speed = 30
    
    -- second key (10 blocks to the left of first key)
    local key2 = make_actor(35,29.5,1.5)
    key2.w=0.25 
    key2.h=0.25
    key2.is_solid = false
    key2.frames = 2
    key2.anim_speed = 30
    
    -- third key (14 blocks down and 3 blocks right from second key)
    local key3 = make_actor(35,32.5,14.5)  -- 29.5 + 3 = 32.5 x-coordinate, 1.5 + 13 = 14.5 y-coordinate
    key3.w=0.25 
    key3.h=0.25
    key3.is_solid = false
    key3.frames = 2
    key3.anim_speed = 30
    
    -- killer ball (horizontal movement)
    killer_ball = make_actor(5, 18,3.5)  -- using sprite 5, position at x=18, y=3.5
    killer_ball.dx = 0.15  -- horizontal speed
    killer_ball.dy = 0  -- no vertical movement
    killer_ball.bounce = 1  -- full bounce against walls
    killer_ball.friction = 0  -- no friction to maintain speed
    killer_ball.frames = 4  -- using frames 5-8 (total of 4 frames)
    killer_ball.anim_speed = 10  -- animation speed
    killer_ball.w = 0.45  -- slightly larger width for better collision detection
    killer_ball.h = 0.45  -- slightly larger height for better collision detection
    
    -- second killer ball (7 blocks below the first one)
    killer_ball2 = make_actor(5, 18, 10.5)  -- same x, but 7 tiles down from the first killer ball (3.5 + 7 = 10.5)
    killer_ball2.dx = 0.15  -- same horizontal speed
    killer_ball2.dy = 0  -- no vertical movement
    killer_ball2.bounce = 1  -- full bounce against walls
    killer_ball2.friction = 0  -- no friction to maintain speed
    killer_ball2.frames = 4  -- using frames 5-8 (total of 4 frames)
    killer_ball2.anim_speed = 10  -- animation speed
    killer_ball2.w = 0.45  -- slightly larger width for better collision detection
    killer_ball2.h = 0.45  -- slightly larger height for better collision detection
    
    -- vertical bat enemy (moves up and down)
    vertical_bat = make_actor(5, 23.5, 7)  -- using sprite 5, position at x=23.5, y=7
    vertical_bat.dx = 0  -- no horizontal movement
    vertical_bat.dy = 0.15  -- vertical speed
    vertical_bat.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat.friction = 0  -- no friction to maintain speed
    vertical_bat.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat.anim_speed = 10  -- animation speed
    vertical_bat.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat.is_killer = true  -- flag to identify it as a killer object
    
    -- second vertical bat (10 blocks to the right of the first one)
    vertical_bat2 = make_actor(5, 33.5, 10)  -- position at x=33.5, y=10
    vertical_bat2.dx = 0  -- no horizontal movement
    vertical_bat2.dy = 0.15  -- vertical speed
    vertical_bat2.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat2.friction = 0  -- no friction to maintain speed
    vertical_bat2.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat2.anim_speed = 10  -- animation speed
    vertical_bat2.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat2.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat2.is_killer = true  -- flag to identify it as a killer object
    
    -- third vertical bat (4 blocks to the right of the second one)
    vertical_bat3 = make_actor(5, 37.5, 10)  -- 33.5 + 4 = 37.5 x-coordinate, same y as second bat
    vertical_bat3.dx = 0  -- no horizontal movement
    vertical_bat3.dy = 0.15  -- vertical speed
    vertical_bat3.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat3.friction = 0  -- no friction to maintain speed
    vertical_bat3.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat3.anim_speed = 10  -- animation speed
    vertical_bat3.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat3.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat3.is_killer = true  -- flag to identify it as a killer object
    
    -- fourth vertical bat (4 blocks to the right of the third one)
    vertical_bat4 = make_actor(5, 41.5, 10)  -- 37.5 + 4 = 41.5 x-coordinate, same y as second and third bats
    vertical_bat4.dx = 0  -- no horizontal movement
    vertical_bat4.dy = 0.15  -- vertical speed
    vertical_bat4.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat4.friction = 0  -- no friction to maintain speed
    vertical_bat4.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat4.anim_speed = 10  -- animation speed
    vertical_bat4.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat4.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat4.is_killer = true  -- flag to identify it as a killer object
    
    -- fifth vertical bat (4 blocks to the right of the fourth one)
    vertical_bat5 = make_actor(5, 45.5, 10)  -- 41.5 + 4 = 45.5 x-coordinate, same y as other bats
    vertical_bat5.dx = 0  -- no horizontal movement
    vertical_bat5.dy = 0.15  -- vertical speed
    vertical_bat5.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat5.friction = 0  -- no friction to maintain speed
    vertical_bat5.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat5.anim_speed = 10  -- animation speed
    vertical_bat5.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat5.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat5.is_killer = true  -- flag to identify it as a killer object
    
    -- sixth vertical bat (3 blocks to the left and 3 blocks down from the fifth one)
    vertical_bat6 = make_actor(5, 42.5, 13)  -- 45.5 - 3 = 42.5 x-coordinate, 10 + 3 = 13 y-coordinate
    vertical_bat6.dx = 0  -- no horizontal movement
    vertical_bat6.dy = 0.15  -- vertical speed
    vertical_bat6.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat6.friction = 0  -- no friction to maintain speed
    vertical_bat6.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat6.anim_speed = 10  -- animation speed
    vertical_bat6.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat6.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat6.is_killer = true  -- flag to identify it as a killer object
    
    -- seventh vertical bat (8 blocks to the left of the sixth one)
    vertical_bat7 = make_actor(5, 34.5, 13)  -- 42.5 - 8 = 34.5 x-coordinate, same y as sixth bat
    vertical_bat7.dx = 0  -- no horizontal movement
    vertical_bat7.dy = 0.15  -- vertical speed
    vertical_bat7.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat7.friction = 0  -- no friction to maintain speed
    vertical_bat7.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat7.anim_speed = 10  -- animation speed
    vertical_bat7.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat7.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat7.is_killer = true  -- flag to identify it as a killer object
    
    -- also add flags to the killer balls for consistency
    killer_ball.is_killer = true
    killer_ball2.is_killer = true
    
    sfx(0) -- play death sound
end

function _init()
    -- initialize death_count and key_count to 0 
    death_count = 0
    key_count = 0
    
    -- instead of calling reset_game, we'll set up the initial state directly
    actor = {}
    has_key = false
    
    -- make player
    pl = make_actor(21,14.5,14)
    pl.frames=4
    
    -- bouncy ball (vertical only)
    local ball = make_actor(33,8.5,11)
    ball.dx = 0
    ball.dy = -0.1
    ball.friction = 0.02
    ball.bounce = 1
    
    -- door entity (needs to be created on first load)
    local door = make_actor(48,46.5,14.5)
    door.w = 0.5 
    door.h = 0.5
    door.is_solid = true
    door.is_door = true
    door.frames = 1
    
    -- create only the intended keys
    local key1 = make_actor(35,11.5,1.5)
    key1.w=0.25 
    key1.h=0.25
    key1.is_solid = false
    key1.frames = 2
    key1.anim_speed = 30
    
    local key2 = make_actor(35,29.5,1.5)
    key2.w=0.25 
    key2.h=0.25
    key2.is_solid = false
    key2.frames = 2
    key2.anim_speed = 30
    
    local key3 = make_actor(35,32.5,14.5)  -- same coordinates as in _init
    key3.w=0.25 
    key3.h=0.25
    key3.is_solid = false
    key3.frames = 2
    key3.anim_speed = 30
    
    -- killer ball (horizontal movement)
    killer_ball = make_actor(5, 18,3.5)
    killer_ball.dx = 0.15
    killer_ball.dy = 0
    killer_ball.bounce = 1
    killer_ball.friction = 0
    killer_ball.frames = 4
    killer_ball.anim_speed = 10
    killer_ball.w = 0.45
    killer_ball.h = 0.45
    killer_ball.is_killer = true
    
    -- second killer ball
    killer_ball2 = make_actor(5, 18, 10.5)
    killer_ball2.dx = 0.15
    killer_ball2.dy = 0
    killer_ball2.bounce = 1
    killer_ball2.friction = 0
    killer_ball2.frames = 4
    killer_ball2.anim_speed = 10
    killer_ball2.w = 0.45
    killer_ball2.h = 0.45
    killer_ball2.is_killer = true
    
    -- vertical bats
    vertical_bat = make_actor(5, 23.5, 7)
    vertical_bat.dx = 0
    vertical_bat.dy = 0.15
    vertical_bat.bounce = 1
    vertical_bat.friction = 0
    vertical_bat.frames = 4
    vertical_bat.anim_speed = 10
    vertical_bat.w = 0.45
    vertical_bat.h = 0.45
    vertical_bat.is_killer = true
    
    vertical_bat2 = make_actor(5, 33.5, 10)
    vertical_bat2.dx = 0
    vertical_bat2.dy = 0.15
    vertical_bat2.bounce = 1
    vertical_bat2.friction = 0
    vertical_bat2.frames = 4
    vertical_bat2.anim_speed = 10
    vertical_bat2.w = 0.45
    vertical_bat2.h = 0.45
    vertical_bat2.is_killer = true
    
    vertical_bat3 = make_actor(5, 37.5, 10)
    vertical_bat3.dx = 0
    vertical_bat3.dy = 0.15
    vertical_bat3.bounce = 1
    vertical_bat3.friction = 0
    vertical_bat3.frames = 4
    vertical_bat3.anim_speed = 10
    vertical_bat3.w = 0.45
    vertical_bat3.h = 0.45
    vertical_bat3.is_killer = true
    
    vertical_bat4 = make_actor(5, 41.5, 10)
    vertical_bat4.dx = 0
    vertical_bat4.dy = 0.15
    vertical_bat4.bounce = 1
    vertical_bat4.friction = 0
    vertical_bat4.frames = 4
    vertical_bat4.anim_speed = 10
    vertical_bat4.w = 0.45
    vertical_bat4.h = 0.45
    vertical_bat4.is_killer = true
    
    vertical_bat5 = make_actor(5, 45.5, 10)
    vertical_bat5.dx = 0
    vertical_bat5.dy = 0.15
    vertical_bat5.bounce = 1
    vertical_bat5.friction = 0
    vertical_bat5.frames = 4
    vertical_bat5.anim_speed = 10
    vertical_bat5.w = 0.45
    vertical_bat5.h = 0.45
    vertical_bat5.is_killer = true
    
    vertical_bat6 = make_actor(5, 42.5, 13)
    vertical_bat6.dx = 0
    vertical_bat6.dy = 0.15
    vertical_bat6.bounce = 1
    vertical_bat6.friction = 0
    vertical_bat6.frames = 4
    vertical_bat6.anim_speed = 10
    vertical_bat6.w = 0.45
    vertical_bat6.h = 0.45
    vertical_bat6.is_killer = true
    
    vertical_bat7 = make_actor(5, 34.5, 13)
    vertical_bat7.dx = 0
    vertical_bat7.dy = 0.15
    vertical_bat7.bounce = 1
    vertical_bat7.friction = 0
    vertical_bat7.frames = 4
    vertical_bat7.anim_speed = 10
    vertical_bat7.w = 0.45
    vertical_bat7.h = 0.45
    vertical_bat7.is_killer = true
end

-- check if a tile is a spike
function is_spike(x, y)
    local val = mget(x, y)
    -- including both original spikes (53-56) and new spikes (37-40)
    return (val >= 53 and val <= 56) or (val >= 37 and val <= 40)
end

-- check if an actor is touching spikes
function check_spike_collision(a)
    -- check all four corners and center points
    local points = {
        {a.x - a.w, a.y - a.h}, -- top left
        {a.x + a.w, a.y - a.h}, -- top right
        {a.x - a.w, a.y + a.h}, -- bottom left
        {a.x + a.w, a.y + a.h}, -- bottom right
        {a.x, a.y},             -- center
        {a.x - a.w, a.y},       -- middle left
        {a.x + a.w, a.y},       -- middle right
        {a.x, a.y - a.h},       -- middle top
        {a.x, a.y + a.h}        -- middle bottom
    }
    
    for point in all(points) do
        if is_spike(flr(point[1]), flr(point[2])) then
            return true
        end
    end
    return false
end

function solid(x, y)
    val=mget(x, y)
    return fget(val, 1)
end

function solid_area(x,y,w,h)
    return 
        solid(x-w,y-h) or
        solid(x+w,y-h) or
        solid(x-w,y+h) or
        solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
    for a2 in all(actor) do
        if a2 != a then
            local x=(a.x+dx) - a2.x
            local y=(a.y+dy) - a2.y
            
            -- check for key collection
            if a.k == 35 and a2 == pl then
                if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                    print_debug("key collection collision detected")
                    collide_event(pl,a)
                    return false
                end
            end
            
            -- check for killer objects collision with player
            if a == pl and a2.is_killer then
                if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                    print_debug("killer collision detected")
                    reset_game()
                    return false
                end
            end
            
            -- skip collision if either actor is not solid
            if not a2.is_solid or not a.is_solid then
                return false
            end
            
            if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                if (dx != 0 and abs(x) < abs(a.x-a2.x)) then
                    if a.k == 33 then
                        a.dx = 0
                    elseif a2.k == 33 then
                        a2.dx = 0
                    else
                        v=abs(a.dx)>abs(a2.dx) and a.dx or a2.dx
                        a.dx,a2.dx = v,v
                    end
                    
                    local ca = collide_event(a,a2) or collide_event(a2,a)
                    return not ca
                end
                
                if (dy != 0 and abs(y) < abs(a.y-a2.y)) then
                    v=abs(a.dy)>abs(a2.dy) and a.dy or a2.dy
                    a.dy,a2.dy = v,v
                    
                    local ca = collide_event(a,a2) or collide_event(a2,a)
                    return not ca
                end
            end
        end
    end
    return false
end

function solid_a(a, dx, dy)
    if solid_area(a.x+dx,a.y+dy, a.w,a.h) then
        return true 
    end
    return solid_actor(a, dx, dy) 
end

function collide_event(a1,a2)
    if (a1==pl and a2.k==35) then
        print_debug("key collected!")
        del(actor,a2)
        has_key = true
        key_count += 0.5
        print_debug("has_key set to true")
        print_debug("key count increased to: " .. key_count)
        sfx(3)
        return true
    end
    
    -- door collision check
    if ((a1==pl and a2.is_door) or (a2==pl and a1.is_door)) then
        if key_count >= 3 then
            print_debug("door opened!")
            if a1.is_door then
                del(actor,a1)
            else
                del(actor,a2)
            end
            key_count = 0
            sfx(3)
            return true
        elseif key_count == 3 then  -- changed from 1 to 3
            -- change door sprite to 0 and make it non-solid
            if a1.is_door then
                a1.k = 0
                a1.is_solid = false
            else
                a2.k = 0
                a2.is_solid = false
            end
            key_count = 0  -- reset key count after transformation
            sfx(2)
            return true
        end
        -- if not enough keys, keep door solid by not returning true
        return false
    end
    
    -- if player collides with any killer object, reset the game
    if (a1 == pl and a2.is_killer) or (a2 == pl and a1.is_killer) then
        print_debug("killed by enemy")
        reset_game()
        return true
    end
    
    sfx(2)
    return false
end

-- simplified killer object check
function check_killer_objects()
    for a in all(actor) do
        if a.is_killer and pl then
            -- slightly larger hitbox for the killer object
            local killer_w = a.w * 1.2
            local killer_h = a.h * 1.2
            
            -- calculate the distance between the two actors' centers
            local x = pl.x - a.x
            local y = pl.y - a.y
            
            -- check for rectangular hitbox collision
            if (abs(x) < (pl.w + killer_w)) and (abs(y) < (pl.h + killer_h)) then
                return true
            end
            
            -- additional check with a circular hitbox
            local distance_squared = x*x + y*y
            local collision_radius = (pl.w + killer_w) * 0.8
            
            if distance_squared < (collision_radius * collision_radius) then
                return true
            end
        end
    end
    return false
end

function move_actor(a)
    if a == pl then
        a.dy += a.gravity
        
        if a.dy > a.max_fall_speed then
            a.dy = a.max_fall_speed
        end
        
        -- check for spike collision
        if check_spike_collision(a) then
            reset_game()
            return
        end
    end
    
    if a.k == 33 then
        a.dx = 0
    end

    if not solid_a(a, a.dx, 0) then
        a.x += a.dx
    else
        a.dx *= -a.bounce
    end

    if not solid_a(a, 0, a.dy) then
        a.y += a.dy
        a.grounded = false
    else
        if a.dy > 0 then
            a.grounded = true
        end
        a.dy *= -a.bounce
        if a == pl then
            a.dy = 0
        end
    end
    
    -- only apply friction to non-player actors
    if a != pl then
        a.dx *= (1-a.friction)
    end
    
    -- update animation
    if a.is_killer or a.k == 35 then
        a.anim_timer += 1
        if a.anim_timer >= a.anim_speed then
            a.anim_timer = 0
            a.frame = (a.frame + 1) % a.frames
        end
    else
        a.frame += abs(a.dx) * 4
        a.frame %= a.frames
    end
    
    a.t += 1
end

function control_player(pl)
    local accel = 0.05
    local max_speed = 0.2
    local deadzone = 0.01
    
    -- apply movement based on input
    if btn(0) then 
        pl.dx -= accel
        if pl.dx < -max_speed then pl.dx = -max_speed end
    elseif btn(1) then
        pl.dx += accel
        if pl.dx > max_speed then pl.dx = max_speed end
    else
        -- no horizontal input - stop immediately
        pl.dx = 0
    end
    
    -- apply deadzone
    if abs(pl.dx) < deadzone then
        pl.dx = 0
    end
    
    if (btn(2) and pl.grounded) then
        pl.dy = pl.jump_force
        pl.grounded = false
        sfx(1)
    end
end

function _update()
    -- check for r key press to reset death count and game
    if btnp(5) then  -- btn(5) is the r key in pico-8
        death_count = 0
        print_debug("death count manually reset")
        
        -- reset the game state too - by using reset_game(),
        -- but without incrementing the death counter
        actor = {}
        has_key = false
        key_count = 0
        
        -- recreate all initial actors (same code as in reset_game but without death increment)
        -- create all initial actors
        pl = make_actor(21,14.5,14)
        pl.frames=4
        
        -- bouncy ball (vertical only)
        local ball = make_actor(33,8.5,11)
        ball.dx=0
        ball.dy=-0.1
        ball.friction=0.02
        ball.bounce=1
        
        -- first key (original spawn)
        local key1 = make_actor(35,11.5,1.5)
        key1.w=0.25 
        key1.h=0.25
        key1.is_solid = false
        key1.frames = 2
        key1.anim_speed = 30
        
        -- second key (10 blocks to the left of first key)
        local key2 = make_actor(35,29.5,1.5)
        key2.w=0.25 
        key2.h=0.25
        key2.is_solid = false
        key2.frames = 2
        key2.anim_speed = 30
        
        -- third key (4 blocks right and 14 blocks down from second key)
        local key3 = make_actor(35,20.5,1.5)  -- new test coordinates
        key3.w=0.25 
        key3.h=0.25
        key3.is_solid = false
        key3.frames = 2
        key3.anim_speed = 30
        
        -- killer ball (horizontal movement)
        killer_ball = make_actor(5, 18,3.5)  -- using sprite 5, position at x=18, y=3.5
        killer_ball.dx = 0.15  -- horizontal speed
        killer_ball.dy = 0  -- no vertical movement
        killer_ball.bounce = 1  -- full bounce against walls
        killer_ball.friction = 0  -- no friction to maintain speed
        killer_ball.frames = 4  -- using frames 5-8 (total of 4 frames)
        killer_ball.anim_speed = 10  -- animation speed
        killer_ball.w = 0.45  -- slightly larger width for better collision detection
        killer_ball.h = 0.45  -- slightly larger height for better collision detection
        
        -- second killer ball (7 blocks below the first one)
        killer_ball2 = make_actor(5, 18, 10.5)  -- same x, but 7 tiles down from the first killer ball (3.5 + 7 = 10.5)
        killer_ball2.dx = 0.15  -- same horizontal speed
        killer_ball2.dy = 0  -- no vertical movement
        killer_ball2.bounce = 1  -- full bounce against walls
        killer_ball2.friction = 0  -- no friction to maintain speed
        killer_ball2.frames = 4  -- using frames 5-8 (total of 4 frames)
        killer_ball2.anim_speed = 10  -- animation speed
        killer_ball2.w = 0.45  -- slightly larger width for better collision detection
        killer_ball2.h = 0.45  -- slightly larger height for better collision detection
        
        -- vertical bat enemy (moves up and down)
        vertical_bat = make_actor(5, 23.5, 7)  -- using sprite 5, position at x=23.5, y=7
        vertical_bat.dx = 0  -- no horizontal movement
        vertical_bat.dy = 0.15  -- vertical speed
        vertical_bat.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat.friction = 0  -- no friction to maintain speed
        vertical_bat.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat.anim_speed = 10  -- animation speed
        vertical_bat.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat.is_killer = true  -- flag to identify it as a killer object
        
        -- second vertical bat (10 blocks to the right of the first one)
        vertical_bat2 = make_actor(5, 33.5, 10)  -- position at x=33.5, y=10
        vertical_bat2.dx = 0  -- no horizontal movement
        vertical_bat2.dy = 0.15  -- vertical speed
        vertical_bat2.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat2.friction = 0  -- no friction to maintain speed
        vertical_bat2.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat2.anim_speed = 10  -- animation speed
        vertical_bat2.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat2.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat2.is_killer = true  -- flag to identify it as a killer object
        
        -- third vertical bat (4 blocks to the right of the second one)
        vertical_bat3 = make_actor(5, 37.5, 10)  -- 33.5 + 4 = 37.5 x-coordinate, same y as second bat
        vertical_bat3.dx = 0  -- no horizontal movement
        vertical_bat3.dy = 0.15  -- vertical speed
        vertical_bat3.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat3.friction = 0  -- no friction to maintain speed
        vertical_bat3.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat3.anim_speed = 10  -- animation speed
        vertical_bat3.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat3.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat3.is_killer = true  -- flag to identify it as a killer object
        
        -- fourth vertical bat (4 blocks to the right of the third one)
        vertical_bat4 = make_actor(5, 41.5, 10)  -- 37.5 + 4 = 41.5 x-coordinate, same y as second and third bats
        vertical_bat4.dx = 0  -- no horizontal movement
        vertical_bat4.dy = 0.15  -- vertical speed
        vertical_bat4.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat4.friction = 0  -- no friction to maintain speed
        vertical_bat4.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat4.anim_speed = 10  -- animation speed
        vertical_bat4.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat4.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat4.is_killer = true  -- flag to identify it as a killer object
        
        -- fifth vertical bat (4 blocks to the right of the fourth one)
        vertical_bat5 = make_actor(5, 45.5, 10)  -- 41.5 + 4 = 45.5 x-coordinate, same y as other bats
        vertical_bat5.dx = 0  -- no horizontal movement
        vertical_bat5.dy = 0.15  -- vertical speed
        vertical_bat5.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat5.friction = 0  -- no friction to maintain speed
        vertical_bat5.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat5.anim_speed = 10  -- animation speed
        vertical_bat5.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat5.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat5.is_killer = true  -- flag to identify it as a killer object
        
        -- sixth vertical bat (3 blocks to the left and 3 blocks down from the fifth one)
        vertical_bat6 = make_actor(5, 42.5, 13)  -- 45.5 - 3 = 42.5 x-coordinate, 10 + 3 = 13 y-coordinate
        vertical_bat6.dx = 0  -- no horizontal movement
        vertical_bat6.dy = 0.15  -- vertical speed
        vertical_bat6.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat6.friction = 0  -- no friction to maintain speed
        vertical_bat6.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat6.anim_speed = 10  -- animation speed
        vertical_bat6.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat6.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat6.is_killer = true  -- flag to identify it as a killer object
        
        -- seventh vertical bat (8 blocks to the left of the sixth one)
        vertical_bat7 = make_actor(5, 34.5, 13)  -- 42.5 - 8 = 34.5 x-coordinate, same y as sixth bat
        vertical_bat7.dx = 0  -- no horizontal movement
        vertical_bat7.dy = 0.15  -- vertical speed
        vertical_bat7.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat7.friction = 0  -- no friction to maintain speed
        vertical_bat7.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat7.anim_speed = 10  -- animation speed
        vertical_bat7.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat7.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat7.is_killer = true  -- flag to identify it as a killer object
    end
    
    control_player(pl)
    foreach(actor, move_actor)
    
    -- check killer objects collision after all actors have moved
    if check_killer_objects() then
        reset_game()
    end
end

function draw_actor(a)
    local sx = (a.x * 8) - 4
    local sy = (a.y * 8) - 4
    spr(a.k + a.frame, sx, sy)
end

function _draw()
    cls()
    
    room_x=flr(pl.x/16)
    room_y=flr(pl.y/16)
    camera(room_x*128,room_y*128)
    
    map()
    foreach(actor,draw_actor)
    
    -- draw death counter (bottom left of the screen)
    local cam_x = room_x*128
    local cam_y = room_y*128
    
    -- position for bottom left - death counter
    local death_counter_x = cam_x + 2
    local death_counter_y = cam_y + 120  -- pico-8 screen is 128x128, so 120 is near the bottom
    
    -- draw a small background for the death counter
    rectfill(death_counter_x, death_counter_y, death_counter_x + 40, death_counter_y + 8, 0) -- black background
    
    -- draw the text for the death counter
    print("deaths: " .. death_count, death_counter_x + 2, death_counter_y + 2, 7) -- white text (color 7)
    
    -- position for bottom right - key counter
    local key_counter_x = cam_x + 85  -- positioned to be in bottom right
    local key_counter_y = cam_y + 120  -- same height as death counter
    
    -- draw a small background for the key counter
    rectfill(key_counter_x, key_counter_y, key_counter_x + 40, key_counter_y + 8, 0) -- black background
    
    -- draw the text for the key counter
    print("keys: " .. key_count, key_counter_x + 2, key_counter_y + 2, 10) -- yellow text (color 10)
end-- wall and actor collisions
-- by zep (modified with gravity and spikes)

actor = {} -- all actors
pl = nil -- store player reference globally
has_key = false -- global flag for key collection
debug_enabled = false -- toggle debug prints
killer_ball = nil -- global reference to killer ball
killer_ball2 = nil -- global reference to second killer ball
vertical_bat = nil -- global reference to vertical bat
vertical_bat2 = nil -- global reference to second vertical bat
vertical_bat3 = nil -- global reference to third vertical bat
vertical_bat4 = nil -- global reference to fourth vertical bat
vertical_bat5 = nil -- global reference to fifth vertical bat
vertical_bat6 = nil -- global reference to sixth vertical bat
vertical_bat7 = nil -- global reference to seventh vertical bat
death_count = 0 -- death counter
key_count = 0 -- counter for collected keys

function print_debug(msg)
    if debug_enabled then
        print(msg)
    end
end

-- make an actor
-- and add to global collection
-- x,y means center of the actor
-- in map tiles
function make_actor(k, x, y)
    a={
        k = k,
        x = x,
        y = y,
        dx = 0,
        dy = 0,     
        frame = 0,
        t = 0,
        friction = 0.15,
        bounce  = 0.3,
        frames = 2,
        
        w = 0.4,
        h = 0.4,
        
        grounded = false,
        gravity = 0.03,
        max_fall_speed = 0.35,
        jump_force = -0.50,
        
        is_solid = true,
        
        anim_timer = 0,
        anim_speed = 120
    }
    
    print_debug("created actor with sprite: " .. k)
    add(actor,a)
    return a
end

function reset_game()
    print_debug("\n--- game reset ---")
    -- increment death counter
    death_count += 1
    print_debug("death count: " .. death_count)
    
    -- clear all actors and reset key flag
    actor = {}
    has_key = false
    key_count = 0 -- reset key counter on death
    print_debug("key count reset to 0")
    
    -- recreate all initial actors
    -- make player
    pl = make_actor(21,14.5,14)
    pl.frames=4
    
    -- door entity
    local door = make_actor(48,46.5,14.5)  -- adjusted position to x=46.5, y=14.5
    door.w = 0.5 
    door.h = 0.5
    door.is_solid = true
    door.is_door = true
    door.frames = 1  -- door doesn't animate
    
    -- bouncy ball (vertical only)
    local ball = make_actor(33,8.5,11)
    ball.dx = 0
    ball.dy = -0.1
    ball.friction = 0.02
    ball.bounce = 1
    
    -- first key (original spawn)
    local key1 = make_actor(35,11.5,1.5)
    key1.w=0.25 
    key1.h=0.25
    key1.is_solid = false
    key1.frames = 2
    key1.anim_speed = 30
    
    -- second key (10 blocks to the left of first key)
    local key2 = make_actor(35,29.5,1.5)
    key2.w=0.25 
    key2.h=0.25
    key2.is_solid = false
    key2.frames = 2
    key2.anim_speed = 30
    
    -- third key (14 blocks down and 3 blocks right from second key)
    local key3 = make_actor(35,32.5,14.5)  -- 29.5 + 3 = 32.5 x-coordinate, 1.5 + 13 = 14.5 y-coordinate
    key3.w=0.25 
    key3.h=0.25
    key3.is_solid = false
    key3.frames = 2
    key3.anim_speed = 30
    
    -- killer ball (horizontal movement)
    killer_ball = make_actor(5, 18,3.5)  -- using sprite 5, position at x=18, y=3.5
    killer_ball.dx = 0.15  -- horizontal speed
    killer_ball.dy = 0  -- no vertical movement
    killer_ball.bounce = 1  -- full bounce against walls
    killer_ball.friction = 0  -- no friction to maintain speed
    killer_ball.frames = 4  -- using frames 5-8 (total of 4 frames)
    killer_ball.anim_speed = 10  -- animation speed
    killer_ball.w = 0.45  -- slightly larger width for better collision detection
    killer_ball.h = 0.45  -- slightly larger height for better collision detection
    
    -- second killer ball (7 blocks below the first one)
    killer_ball2 = make_actor(5, 18, 10.5)  -- same x, but 7 tiles down from the first killer ball (3.5 + 7 = 10.5)
    killer_ball2.dx = 0.15  -- same horizontal speed
    killer_ball2.dy = 0  -- no vertical movement
    killer_ball2.bounce = 1  -- full bounce against walls
    killer_ball2.friction = 0  -- no friction to maintain speed
    killer_ball2.frames = 4  -- using frames 5-8 (total of 4 frames)
    killer_ball2.anim_speed = 10  -- animation speed
    killer_ball2.w = 0.45  -- slightly larger width for better collision detection
    killer_ball2.h = 0.45  -- slightly larger height for better collision detection
    
    -- vertical bat enemy (moves up and down)
    vertical_bat = make_actor(5, 23.5, 7)  -- using sprite 5, position at x=23.5, y=7
    vertical_bat.dx = 0  -- no horizontal movement
    vertical_bat.dy = 0.15  -- vertical speed
    vertical_bat.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat.friction = 0  -- no friction to maintain speed
    vertical_bat.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat.anim_speed = 10  -- animation speed
    vertical_bat.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat.is_killer = true  -- flag to identify it as a killer object
    
    -- second vertical bat (10 blocks to the right of the first one)
    vertical_bat2 = make_actor(5, 33.5, 10)  -- position at x=33.5, y=10
    vertical_bat2.dx = 0  -- no horizontal movement
    vertical_bat2.dy = 0.15  -- vertical speed
    vertical_bat2.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat2.friction = 0  -- no friction to maintain speed
    vertical_bat2.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat2.anim_speed = 10  -- animation speed
    vertical_bat2.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat2.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat2.is_killer = true  -- flag to identify it as a killer object
    
    -- third vertical bat (4 blocks to the right of the second one)
    vertical_bat3 = make_actor(5, 37.5, 10)  -- 33.5 + 4 = 37.5 x-coordinate, same y as second bat
    vertical_bat3.dx = 0  -- no horizontal movement
    vertical_bat3.dy = 0.15  -- vertical speed
    vertical_bat3.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat3.friction = 0  -- no friction to maintain speed
    vertical_bat3.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat3.anim_speed = 10  -- animation speed
    vertical_bat3.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat3.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat3.is_killer = true  -- flag to identify it as a killer object
    
    -- fourth vertical bat (4 blocks to the right of the third one)
    vertical_bat4 = make_actor(5, 41.5, 10)  -- 37.5 + 4 = 41.5 x-coordinate, same y as second and third bats
    vertical_bat4.dx = 0  -- no horizontal movement
    vertical_bat4.dy = 0.15  -- vertical speed
    vertical_bat4.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat4.friction = 0  -- no friction to maintain speed
    vertical_bat4.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat4.anim_speed = 10  -- animation speed
    vertical_bat4.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat4.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat4.is_killer = true  -- flag to identify it as a killer object
    
    -- fifth vertical bat (4 blocks to the right of the fourth one)
    vertical_bat5 = make_actor(5, 45.5, 10)  -- 41.5 + 4 = 45.5 x-coordinate, same y as other bats
    vertical_bat5.dx = 0  -- no horizontal movement
    vertical_bat5.dy = 0.15  -- vertical speed
    vertical_bat5.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat5.friction = 0  -- no friction to maintain speed
    vertical_bat5.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat5.anim_speed = 10  -- animation speed
    vertical_bat5.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat5.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat5.is_killer = true  -- flag to identify it as a killer object
    
    -- sixth vertical bat (3 blocks to the left and 3 blocks down from the fifth one)
    vertical_bat6 = make_actor(5, 42.5, 13)  -- 45.5 - 3 = 42.5 x-coordinate, 10 + 3 = 13 y-coordinate
    vertical_bat6.dx = 0  -- no horizontal movement
    vertical_bat6.dy = 0.15  -- vertical speed
    vertical_bat6.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat6.friction = 0  -- no friction to maintain speed
    vertical_bat6.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat6.anim_speed = 10  -- animation speed
    vertical_bat6.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat6.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat6.is_killer = true  -- flag to identify it as a killer object
    
    -- seventh vertical bat (8 blocks to the left of the sixth one)
    vertical_bat7 = make_actor(5, 34.5, 13)  -- 42.5 - 8 = 34.5 x-coordinate, same y as sixth bat
    vertical_bat7.dx = 0  -- no horizontal movement
    vertical_bat7.dy = 0.15  -- vertical speed
    vertical_bat7.bounce = 1  -- full bounce against walls/ceiling/floor
    vertical_bat7.friction = 0  -- no friction to maintain speed
    vertical_bat7.frames = 4  -- using frames 5-8 (total of 4 frames)
    vertical_bat7.anim_speed = 10  -- animation speed
    vertical_bat7.w = 0.45  -- slightly larger width for better collision detection
    vertical_bat7.h = 0.45  -- slightly larger height for better collision detection
    vertical_bat7.is_killer = true  -- flag to identify it as a killer object
    
    -- also add flags to the killer balls for consistency
    killer_ball.is_killer = true
    killer_ball2.is_killer = true
    
    sfx(0) -- play death sound
end

function _init()
    -- initialize death_count and key_count to 0 
    death_count = 0
    key_count = 0
    
    -- instead of calling reset_game, we'll set up the initial state directly
    actor = {}
    has_key = false
    
    -- make player
    pl = make_actor(21,14.5,14)
    pl.frames=4
    
    -- bouncy ball (vertical only)
    local ball = make_actor(33,8.5,11)
    ball.dx = 0
    ball.dy = -0.1
    ball.friction = 0.02
    ball.bounce = 1
    
    -- door entity (needs to be created on first load)
    local door = make_actor(48,46.5,14.5)
    door.w = 0.5 
    door.h = 0.5
    door.is_solid = true
    door.is_door = true
    door.frames = 1
    
    -- create only the intended keys
    local key1 = make_actor(35,11.5,1.5)
    key1.w=0.25 
    key1.h=0.25
    key1.is_solid = false
    key1.frames = 2
    key1.anim_speed = 30
    
    local key2 = make_actor(35,29.5,1.5)
    key2.w=0.25 
    key2.h=0.25
    key2.is_solid = false
    key2.frames = 2
    key2.anim_speed = 30
    
    local key3 = make_actor(35,32.5,14.5)  -- same coordinates as in _init
    key3.w=0.25 
    key3.h=0.25
    key3.is_solid = false
    key3.frames = 2
    key3.anim_speed = 30
    
    -- killer ball (horizontal movement)
    killer_ball = make_actor(5, 18,3.5)
    killer_ball.dx = 0.15
    killer_ball.dy = 0
    killer_ball.bounce = 1
    killer_ball.friction = 0
    killer_ball.frames = 4
    killer_ball.anim_speed = 10
    killer_ball.w = 0.45
    killer_ball.h = 0.45
    killer_ball.is_killer = true
    
    -- second killer ball
    killer_ball2 = make_actor(5, 18, 10.5)
    killer_ball2.dx = 0.15
    killer_ball2.dy = 0
    killer_ball2.bounce = 1
    killer_ball2.friction = 0
    killer_ball2.frames = 4
    killer_ball2.anim_speed = 10
    killer_ball2.w = 0.45
    killer_ball2.h = 0.45
    killer_ball2.is_killer = true
    
    -- vertical bats
    vertical_bat = make_actor(5, 23.5, 7)
    vertical_bat.dx = 0
    vertical_bat.dy = 0.15
    vertical_bat.bounce = 1
    vertical_bat.friction = 0
    vertical_bat.frames = 4
    vertical_bat.anim_speed = 10
    vertical_bat.w = 0.45
    vertical_bat.h = 0.45
    vertical_bat.is_killer = true
    
    vertical_bat2 = make_actor(5, 33.5, 10)
    vertical_bat2.dx = 0
    vertical_bat2.dy = 0.15
    vertical_bat2.bounce = 1
    vertical_bat2.friction = 0
    vertical_bat2.frames = 4
    vertical_bat2.anim_speed = 10
    vertical_bat2.w = 0.45
    vertical_bat2.h = 0.45
    vertical_bat2.is_killer = true
    
    vertical_bat3 = make_actor(5, 37.5, 10)
    vertical_bat3.dx = 0
    vertical_bat3.dy = 0.15
    vertical_bat3.bounce = 1
    vertical_bat3.friction = 0
    vertical_bat3.frames = 4
    vertical_bat3.anim_speed = 10
    vertical_bat3.w = 0.45
    vertical_bat3.h = 0.45
    vertical_bat3.is_killer = true
    
    vertical_bat4 = make_actor(5, 41.5, 10)
    vertical_bat4.dx = 0
    vertical_bat4.dy = 0.15
    vertical_bat4.bounce = 1
    vertical_bat4.friction = 0
    vertical_bat4.frames = 4
    vertical_bat4.anim_speed = 10
    vertical_bat4.w = 0.45
    vertical_bat4.h = 0.45
    vertical_bat4.is_killer = true
    
    vertical_bat5 = make_actor(5, 45.5, 10)
    vertical_bat5.dx = 0
    vertical_bat5.dy = 0.15
    vertical_bat5.bounce = 1
    vertical_bat5.friction = 0
    vertical_bat5.frames = 4
    vertical_bat5.anim_speed = 10
    vertical_bat5.w = 0.45
    vertical_bat5.h = 0.45
    vertical_bat5.is_killer = true
    
    vertical_bat6 = make_actor(5, 42.5, 13)
    vertical_bat6.dx = 0
    vertical_bat6.dy = 0.15
    vertical_bat6.bounce = 1
    vertical_bat6.friction = 0
    vertical_bat6.frames = 4
    vertical_bat6.anim_speed = 10
    vertical_bat6.w = 0.45
    vertical_bat6.h = 0.45
    vertical_bat6.is_killer = true
    
    vertical_bat7 = make_actor(5, 34.5, 13)
    vertical_bat7.dx = 0
    vertical_bat7.dy = 0.15
    vertical_bat7.bounce = 1
    vertical_bat7.friction = 0
    vertical_bat7.frames = 4
    vertical_bat7.anim_speed = 10
    vertical_bat7.w = 0.45
    vertical_bat7.h = 0.45
    vertical_bat7.is_killer = true
end

-- check if a tile is a spike
function is_spike(x, y)
    local val = mget(x, y)
    -- including both original spikes (53-56) and new spikes (37-40)
    return (val >= 53 and val <= 56) or (val >= 37 and val <= 40)
end

-- check if an actor is touching spikes
function check_spike_collision(a)
    -- check all four corners and center points
    local points = {
        {a.x - a.w, a.y - a.h}, -- top left
        {a.x + a.w, a.y - a.h}, -- top right
        {a.x - a.w, a.y + a.h}, -- bottom left
        {a.x + a.w, a.y + a.h}, -- bottom right
        {a.x, a.y},             -- center
        {a.x - a.w, a.y},       -- middle left
        {a.x + a.w, a.y},       -- middle right
        {a.x, a.y - a.h},       -- middle top
        {a.x, a.y + a.h}        -- middle bottom
    }
    
    for point in all(points) do
        if is_spike(flr(point[1]), flr(point[2])) then
            return true
        end
    end
    return false
end

function solid(x, y)
    val=mget(x, y)
    return fget(val, 1)
end

function solid_area(x,y,w,h)
    return 
        solid(x-w,y-h) or
        solid(x+w,y-h) or
        solid(x-w,y+h) or
        solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
    for a2 in all(actor) do
        if a2 != a then
            local x=(a.x+dx) - a2.x
            local y=(a.y+dy) - a2.y
            
            -- check for key collection
            if a.k == 35 and a2 == pl then
                if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                    print_debug("key collection collision detected")
                    collide_event(pl,a)
                    return false
                end
            end
            
            -- check for killer objects collision with player
            if a == pl and a2.is_killer then
                if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                    print_debug("killer collision detected")
                    reset_game()
                    return false
                end
            end
            
            -- skip collision if either actor is not solid
            if not a2.is_solid or not a.is_solid then
                return false
            end
            
            if ((abs(x) < (a.w+a2.w)) and (abs(y) < (a.h+a2.h))) then
                if (dx != 0 and abs(x) < abs(a.x-a2.x)) then
                    if a.k == 33 then
                        a.dx = 0
                    elseif a2.k == 33 then
                        a2.dx = 0
                    else
                        v=abs(a.dx)>abs(a2.dx) and a.dx or a2.dx
                        a.dx,a2.dx = v,v
                    end
                    
                    local ca = collide_event(a,a2) or collide_event(a2,a)
                    return not ca
                end
                
                if (dy != 0 and abs(y) < abs(a.y-a2.y)) then
                    v=abs(a.dy)>abs(a2.dy) and a.dy or a2.dy
                    a.dy,a2.dy = v,v
                    
                    local ca = collide_event(a,a2) or collide_event(a2,a)
                    return not ca
                end
            end
        end
    end
    return false
end

function solid_a(a, dx, dy)
    if solid_area(a.x+dx,a.y+dy, a.w,a.h) then
        return true 
    end
    return solid_actor(a, dx, dy) 
end

function collide_event(a1,a2)
    if (a1==pl and a2.k==35) then
        print_debug("key collected!")
        del(actor,a2)
        has_key = true
        key_count += 0.5
        print_debug("has_key set to true")
        print_debug("key count increased to: " .. key_count)
        sfx(3)
        return true
    end
    
    -- door collision check
    if ((a1==pl and a2.is_door) or (a2==pl and a1.is_door)) then
        if key_count >= 3 then
            print_debug("door opened!")
            if a1.is_door then
                del(actor,a1)
            else
                del(actor,a2)
            end
            key_count = 0
            sfx(3)
            return true
        elseif key_count == 3 then  -- changed from 1 to 3
            -- change door sprite to 0 and make it non-solid
            if a1.is_door then
                a1.k = 0
                a1.is_solid = false
            else
                a2.k = 0
                a2.is_solid = false
            end
            key_count = 0  -- reset key count after transformation
            sfx(2)
            return true
        end
        -- if not enough keys, keep door solid by not returning true
        return false
    end
    
    -- if player collides with any killer object, reset the game
    if (a1 == pl and a2.is_killer) or (a2 == pl and a1.is_killer) then
        print_debug("killed by enemy")
        reset_game()
        return true
    end
    
    sfx(2)
    return false
end

-- simplified killer object check
function check_killer_objects()
    for a in all(actor) do
        if a.is_killer and pl then
            -- slightly larger hitbox for the killer object
            local killer_w = a.w * 1.2
            local killer_h = a.h * 1.2
            
            -- calculate the distance between the two actors' centers
            local x = pl.x - a.x
            local y = pl.y - a.y
            
            -- check for rectangular hitbox collision
            if (abs(x) < (pl.w + killer_w)) and (abs(y) < (pl.h + killer_h)) then
                return true
            end
            
            -- additional check with a circular hitbox
            local distance_squared = x*x + y*y
            local collision_radius = (pl.w + killer_w) * 0.8
            
            if distance_squared < (collision_radius * collision_radius) then
                return true
            end
        end
    end
    return false
end

function move_actor(a)
    if a == pl then
        a.dy += a.gravity
        
        if a.dy > a.max_fall_speed then
            a.dy = a.max_fall_speed
        end
        
        -- check for spike collision
        if check_spike_collision(a) then
            reset_game()
            return
        end
    end
    
    if a.k == 33 then
        a.dx = 0
    end

    if not solid_a(a, a.dx, 0) then
        a.x += a.dx
    else
        a.dx *= -a.bounce
    end

    if not solid_a(a, 0, a.dy) then
        a.y += a.dy
        a.grounded = false
    else
        if a.dy > 0 then
            a.grounded = true
        end
        a.dy *= -a.bounce
        if a == pl then
            a.dy = 0
        end
    end
    
    -- only apply friction to non-player actors
    if a != pl then
        a.dx *= (1-a.friction)
    end
    
    -- update animation
    if a.is_killer or a.k == 35 then
        a.anim_timer += 1
        if a.anim_timer >= a.anim_speed then
            a.anim_timer = 0
            a.frame = (a.frame + 1) % a.frames
        end
    else
        a.frame += abs(a.dx) * 4
        a.frame %= a.frames
    end
    
    a.t += 1
end

function control_player(pl)
    local accel = 0.05
    local max_speed = 0.2
    local deadzone = 0.01
    
    -- apply movement based on input
    if btn(0) then 
        pl.dx -= accel
        if pl.dx < -max_speed then pl.dx = -max_speed end
    elseif btn(1) then
        pl.dx += accel
        if pl.dx > max_speed then pl.dx = max_speed end
    else
        -- no horizontal input - stop immediately
        pl.dx = 0
    end
    
    -- apply deadzone
    if abs(pl.dx) < deadzone then
        pl.dx = 0
    end
    
    if (btn(2) and pl.grounded) then
        pl.dy = pl.jump_force
        pl.grounded = false
        sfx(1)
    end
end

function _update()
    -- check for r key press to reset death count and game
    if btnp(5) then  -- btn(5) is the r key in pico-8
        death_count = 0
        print_debug("death count manually reset")
        
        -- reset the game state too - by using reset_game(),
        -- but without incrementing the death counter
        actor = {}
        has_key = false
        key_count = 0
        
        -- recreate all initial actors (same code as in reset_game but without death increment)
        -- create all initial actors
        pl = make_actor(21,14.5,14)
        pl.frames=4
        
        -- bouncy ball (vertical only)
        local ball = make_actor(33,8.5,11)
        ball.dx=0
        ball.dy=-0.1
        ball.friction=0.02
        ball.bounce=1
        
        -- first key (original spawn)
        local key1 = make_actor(35,11.5,1.5)
        key1.w=0.25 
        key1.h=0.25
        key1.is_solid = false
        key1.frames = 2
        key1.anim_speed = 30
        
        -- second key (10 blocks to the left of first key)
        local key2 = make_actor(35,29.5,1.5)
        key2.w=0.25 
        key2.h=0.25
        key2.is_solid = false
        key2.frames = 2
        key2.anim_speed = 30
        
        -- third key (4 blocks right and 14 blocks down from second key)
        local key3 = make_actor(35,20.5,1.5)  -- new test coordinates
        key3.w=0.25 
        key3.h=0.25
        key3.is_solid = false
        key3.frames = 2
        key3.anim_speed = 30
        
        -- killer ball (horizontal movement)
        killer_ball = make_actor(5, 18,3.5)  -- using sprite 5, position at x=18, y=3.5
        killer_ball.dx = 0.15  -- horizontal speed
        killer_ball.dy = 0  -- no vertical movement
        killer_ball.bounce = 1  -- full bounce against walls
        killer_ball.friction = 0  -- no friction to maintain speed
        killer_ball.frames = 4  -- using frames 5-8 (total of 4 frames)
        killer_ball.anim_speed = 10  -- animation speed
        killer_ball.w = 0.45  -- slightly larger width for better collision detection
        killer_ball.h = 0.45  -- slightly larger height for better collision detection
        
        -- second killer ball (7 blocks below the first one)
        killer_ball2 = make_actor(5, 18, 10.5)  -- same x, but 7 tiles down from the first killer ball (3.5 + 7 = 10.5)
        killer_ball2.dx = 0.15  -- same horizontal speed
        killer_ball2.dy = 0  -- no vertical movement
        killer_ball2.bounce = 1  -- full bounce against walls
        killer_ball2.friction = 0  -- no friction to maintain speed
        killer_ball2.frames = 4  -- using frames 5-8 (total of 4 frames)
        killer_ball2.anim_speed = 10  -- animation speed
        killer_ball2.w = 0.45  -- slightly larger width for better collision detection
        killer_ball2.h = 0.45  -- slightly larger height for better collision detection
        
        -- vertical bat enemy (moves up and down)
        vertical_bat = make_actor(5, 23.5, 7)  -- using sprite 5, position at x=23.5, y=7
        vertical_bat.dx = 0  -- no horizontal movement
        vertical_bat.dy = 0.15  -- vertical speed
        vertical_bat.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat.friction = 0  -- no friction to maintain speed
        vertical_bat.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat.anim_speed = 10  -- animation speed
        vertical_bat.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat.is_killer = true  -- flag to identify it as a killer object
        
        -- second vertical bat (10 blocks to the right of the first one)
        vertical_bat2 = make_actor(5, 33.5, 10)  -- position at x=33.5, y=10
        vertical_bat2.dx = 0  -- no horizontal movement
        vertical_bat2.dy = 0.15  -- vertical speed
        vertical_bat2.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat2.friction = 0  -- no friction to maintain speed
        vertical_bat2.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat2.anim_speed = 10  -- animation speed
        vertical_bat2.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat2.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat2.is_killer = true  -- flag to identify it as a killer object
        
        -- third vertical bat (4 blocks to the right of the second one)
        vertical_bat3 = make_actor(5, 37.5, 10)  -- 33.5 + 4 = 37.5 x-coordinate, same y as second bat
        vertical_bat3.dx = 0  -- no horizontal movement
        vertical_bat3.dy = 0.15  -- vertical speed
        vertical_bat3.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat3.friction = 0  -- no friction to maintain speed
        vertical_bat3.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat3.anim_speed = 10  -- animation speed
        vertical_bat3.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat3.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat3.is_killer = true  -- flag to identify it as a killer object
        
        -- fourth vertical bat (4 blocks to the right of the third one)
        vertical_bat4 = make_actor(5, 41.5, 10)  -- 37.5 + 4 = 41.5 x-coordinate, same y as second and third bats
        vertical_bat4.dx = 0  -- no horizontal movement
        vertical_bat4.dy = 0.15  -- vertical speed
        vertical_bat4.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat4.friction = 0  -- no friction to maintain speed
        vertical_bat4.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat4.anim_speed = 10  -- animation speed
        vertical_bat4.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat4.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat4.is_killer = true  -- flag to identify it as a killer object
        
        -- fifth vertical bat (4 blocks to the right of the fourth one)
        vertical_bat5 = make_actor(5, 45.5, 10)  -- 41.5 + 4 = 45.5 x-coordinate, same y as other bats
        vertical_bat5.dx = 0  -- no horizontal movement
        vertical_bat5.dy = 0.15  -- vertical speed
        vertical_bat5.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat5.friction = 0  -- no friction to maintain speed
        vertical_bat5.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat5.anim_speed = 10  -- animation speed
        vertical_bat5.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat5.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat5.is_killer = true  -- flag to identify it as a killer object
        
        -- sixth vertical bat (3 blocks to the left and 3 blocks down from the fifth one)
        vertical_bat6 = make_actor(5, 42.5, 13)  -- 45.5 - 3 = 42.5 x-coordinate, 10 + 3 = 13 y-coordinate
        vertical_bat6.dx = 0  -- no horizontal movement
        vertical_bat6.dy = 0.15  -- vertical speed
        vertical_bat6.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat6.friction = 0  -- no friction to maintain speed
        vertical_bat6.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat6.anim_speed = 10  -- animation speed
        vertical_bat6.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat6.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat6.is_killer = true  -- flag to identify it as a killer object
        
        -- seventh vertical bat (8 blocks to the left of the sixth one)
        vertical_bat7 = make_actor(5, 34.5, 13)  -- 42.5 - 8 = 34.5 x-coordinate, same y as sixth bat
        vertical_bat7.dx = 0  -- no horizontal movement
        vertical_bat7.dy = 0.15  -- vertical speed
        vertical_bat7.bounce = 1  -- full bounce against walls/ceiling/floor
        vertical_bat7.friction = 0  -- no friction to maintain speed
        vertical_bat7.frames = 4  -- using frames 5-8 (total of 4 frames)
        vertical_bat7.anim_speed = 10  -- animation speed
        vertical_bat7.w = 0.45  -- slightly larger width for better collision detection
        vertical_bat7.h = 0.45  -- slightly larger height for better collision detection
        vertical_bat7.is_killer = true  -- flag to identify it as a killer object
    end
    
    control_player(pl)
    foreach(actor, move_actor)
    
    -- check killer objects collision after all actors have moved
    if check_killer_objects() then
        reset_game()
    end
end

function draw_actor(a)
    local sx = (a.x * 8) - 4
    local sy = (a.y * 8) - 4
    spr(a.k + a.frame, sx, sy)
end

function _draw()
    cls()
    
    room_x=flr(pl.x/16)
    room_y=flr(pl.y/16)
    camera(room_x*128,room_y*128)
    
    map()
    foreach(actor,draw_actor)
    
    -- draw death counter (bottom left of the screen)
    local cam_x = room_x*128
    local cam_y = room_y*128
    
    -- position for bottom left - death counter
    local death_counter_x = cam_x + 2
    local death_counter_y = cam_y + 120  -- pico-8 screen is 128x128, so 120 is near the bottom
    
    -- draw a small background for the death counter
    rectfill(death_counter_x, death_counter_y, death_counter_x + 40, death_counter_y + 8, 0) -- black background
    
    -- draw the text for the death counter
    print("deaths: " .. death_count, death_counter_x + 2, death_counter_y + 2, 7) -- white text (color 7)
    
    -- position for bottom right - key counter
    local key_counter_x = cam_x + 85  -- positioned to be in bottom right
    local key_counter_y = cam_y + 120  -- same height as death counter
    
    -- draw a small background for the key counter
    rectfill(key_counter_x, key_counter_y, key_counter_x + 40, key_counter_y + 8, 0) -- black background
    
    -- draw the text for the key counter
    print("keys: " .. key_count, key_counter_x + 2, key_counter_y + 2, 10) -- yellow text (color 10)
end
__gfx__
000000003bbbbbb733333bb70cccccc0cccccccc001001000010010000100100001001000000000000000000ccc34ccc00000000cccccccccccccccccccccccc
000000003000000b333433bbd000007c1c111c1c001111000011110000111100001111000000000000000000ccc333cc00000000ccccccccc777c777ccc77c7c
000000003000070b44444444d000770ccccccccc108118010011110010811801008118000000000000000000cc33333c00000000ccc7777777777777c777777c
000000003000000b54444544d000770ccccccccc111661110116611011166111011661100000000000000000c333433c00000000cc7777777777777c77777777
000000003000000b44444554d000000ccccccccc111111111111111111111111111111110000000000000000c334433c00000000c77777777777777777777777
000000003000000b44444444d000000ccc1c11c1011111101111111101111110111111110000000000000000ccc44ccc00000000c7777777c7777cc7cc777777
000000003000000b44544444d000000ccccccccc000110001001100100011000100110010000000000000000cc334ccc00000000cccc777cc77777ccccc7ccc7
000000001111111144444454c1111110cccccccc000000000000000000000000000000000000000000000000c3344ccc00000000cccccccccccccccccccccccc
aaaaaaaa000dd000500dd000cc1cc111cccccccc00bbbb0000bbbb0000bbbb0000bbbb0000000000ccccccccc333333ccccccccc00000000ccccccccaaaaaaaa
a000000a50dddd0050dddd00cccccccccccccccc0b5445000b5445000b5445000b54450000000000cccccccc33334333cccccccc00000000cccc77ccaaaaaaaa
a000000a5dddddd05dddddd0cccccccccccccccc0044440000444400004444044044440000000000cccccccccc4444cccccccccc0000000077777777aaaaaaaa
a000000a507ff700507ff700cccccccccccccccc099aa994499aa990099aa990999aa99000000000cccccccccc3333cccccccccc0000000077777777aaaaaaaa
a000000a50f66f00f0f66f0fcc1c11c1cccccccc409aa900009aa904099aa900009aa99400000000ccccccccc3334333cccccccc0000000077777777aaaaaaaa
a000000af887788058877880cccccccccccccccc0091190000911900409119000091190000000000ccccccc3333444333ccccccc0000000077777777aaaaaaaa
a000000a5057650f50576500cccccccccccccccc0010010001000010001001000100001000000000cccccc33334444c333cccccc00000000c77ccc7caaaaaaaa
aaaaaaaa5220772002207220cccccccccccccccc0620026000000000062002606200002600000000ccccc333cc4444ccc333cccc00000000ccccccccaaaaaaaa
00000000cc7777cc00777700000000000000000000000000d0000000dddddddd0000000d00000000cccccccccc3333cccccccccc000000004443334400000000
00000000c777777c07000070000000000000000000005000dd6000000d6666d0000005dd05500550ccccccccc333433ccccccccc000000004333333430000000
000000007777777770007707aa7000000000000000075000d6660000066665500000556d05500550cccccccc3334433ccccccccc000000003333333333000000
000000007777777770007707a0aaaaaa0000000000075000d6677700006755000555566d00000000ccccccc33c444333cccccccc000000003333333333300000
00000000777777777000000770a00a0aaaa0000000675500d6655550000750000077766d00000000cccccccccc4444c33ccccccc000000003334433333330000
000000007777777770000007aaa00000a0aaaaa706666550d6550000000750000000666d05500550cccccccccc4444cccccccccc000000003444444333333000
00000000c777777c0700007000000000a0a00a0a0d6666d0dd50000000005000000006dd05500550cccccccccc4444cccccccccc000000004444444403330000
00000000cc7777cc00777700000000007aa00000ddddddddd0000000000000000000000d00000000cccccccccc4444cccccccccc000000004444444400000000
aaaaaaaa00888800008888000000000000000000ccccccccdcccccccddddddddcccccccd0000000000000000cc4444cccccccccc555555550004444400000000
a444444a08888880088888800000000000000000cccc5cccdd6ccccccd6666dcccccc5dd0000000000000000cc4444cccccccccc577557750004444400000000
a444444a88888778888887780000000000000000ccc75cccd667ccccc666655ccccc556d0000000000000000cc4444cccccccccc576557750004444400000000
a444444a88888778888887780000000000000000ccc75cccd66777cccc7755ccc555566d0000000000000000cc4444cccccccccc566557750000000000000000
a4444a4a8e8888888e8888880000000000000000cc6755ccd665555cccc75ccccc77766d0000000000000000cc4444cccccccccc555555550000000000000000
a4444a4a8eee88888eee88880000000000000000c666655cd655ccccccc75ccccccc766d0000000000000000cc4444cccccccccc577556750000000000000000
a444444a08ee888008ee88800000000000000000cd6666dcdd5ccccccccc5cccccccc6dd0000000000000000cc4444cccccccccc577556750000000000000000
a444444a00888800008888000000000000000000dddddddddccccccccccccccccccccccd0000000000000000cc4444cccccccccc555555550000000000000000
000000000088888000cccc00880000000ccc0000800888000000cc0000888008000000000088880000cccc000000000000000000000000000000000000000000
00000000088000000cc00cc088800080cc00cc0088880800000ccc00888888800ccccc000088880000cccc000000000000000000000000000000000000000000
00000000080000000c0000c080800080c0000c00080088000c0c0c00000080000c00000000888800000ccc000000000000000000000000000000000000000000
00000000080000000c0000c080080880c0000000888880000ccc0c00000080000cc0000000888000000cc0000000000000000000000000000000000000000000
00000000080000000c0000c080080800c00cc000800880000cccccc00000800000cccc0000088000000cc0000000000000000000000000000000000000000000
00000000088000000c000cc080008800cc00cc00800088000ccc0c000000800000000cc000088000000cc0000000000000000000000000000000000000000000
00000000008888000ccccc00800088000cccc00080000880ccc00c0000008000ccc00cc000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000080000000c0000cc00000800000cccc0000088000000cc0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900090009000000999900000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900090009000000900990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000090009000000900099000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000090009000000900009000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999990009000000900099000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000900009000000900090000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000900099999900909990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000900090000000999000000000000
00000000000000000000000000999900009990000099990009999900009999000000000000000000000000000070000000000000000000000000000000000000
00000000000000000000000000900900090090000090000009900000099009000000000007700070000070000770000000000000000000000000000000000000
00000000000000000000000000900090090990000090000000900000099000000000000000700770000077007700000000000000000000000000000000000000
00000000000000000000000000990990099900000099900000999000009900000000000000700700000007707000000000000000000000000000000000000000
00000000000000000000000000999000090990000099000000009900000999900000000000770700000000700000000000000000000000000000000000000000
00000000000000000000000000900000090090000090000000009900090000900000000000077000000000000000000000000000000000000000000000000000
00000000000000000000000000900000090099000090000009999000009999900000000000077000000000000000000000000000000000000000000000000000
00000000000000000000000000900000090009000099990000000000000000000000000000077000000000000000000000000000000000000000000000000000
00000000999999990099990000000000009999000909990000000000000000000990009000000000900000090009900000000000000000000000000000000000
00000000009999000999090000000000099009000909090000000000000000000090099000000000900000990009900009000900000000000000000000000000
00000000000999000990009000000000090099000909090000000000000000000099090000000000990900900000000009900900000000000000000000000000
00000000000990000900009000000000099990000990099000000000000000000099990000000000999990900009900009900900000000000000000000000000
00000000000990009900009000000000099900000999999000000000000000000009900000000000099099000009900009099900000000000000000000000000
00000000000990009000009000000000090900000990009000000000000000000009000000000000099099000009900009099000000000000000000000000000
00000000000990009900009000000000090099000900009000000000000000000009000000000000099009000009900099009000000000000000000000000000
00000000000990000999990000000000090009900900009000000000000000000009000000000000000000000009900090009000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d30000
__label__
dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc7700000000
d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d0000077d000007700000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
51111111511111115111111151111111511111115111111151111111511111115111111151111111511111115111111151111111511111115111111100000000
dccccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dccccc7700000000
d000007700000000000000000000000000000000000000000000000000000000000000001011101000000000000000000000000000000000d000007700000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000010110100000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005111111100000000
dccccc770000000000000000000000000000000000000000000000000cccccc0000000000000000000000000000000000000000000000000dccccc7700000000
d0000077000000000000000000000000000000000000000000000000d000007c000000000000000000000000000000000000000010111010d000007700000000
d000000c000000000000000000000000000000000000000000000000d000770c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000770c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000101101d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000c000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000011111100000000000000000000000000ffff00000000000000000005111111100000000
0cccccc0dccccc77dccccc77dccccc77000000000000000000000000000000000000000000000000000000000dffd00000000000000000000cccccc000000000
d000007cd0000077d0000077d0000077000000000000000000000000101110100000000000000000000000000ffff0000000000000000000d000007c00000000
d000770cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000882288f00000000000000000d000770c00000000
d000770cd000000cd000000cd000000c0000000000000000000000000000000000000000000000000000000f082280000000000000000000d000770c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000085580000000000000000000d000000c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000101101000000000000000000000000050050000000000000000000d000000c00000000
d000000cd000000cd000000cd000000c00000000000000000000000000000000000000000000000000000000660066000000000000000000d000000c00000000
01111110511111115111111151111111000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000
dccccc7700000000000000000000000000000000000000000000000000000000000000003bbbbbb700000000000000000000000000000000dccccc7700000000
d000007700000000101110100000000000000000000000000000000000000000000000003000000b00000000000000000000000000000000d000007700000000
d000000c00000000000000000000000000000000000000000000000000000000000000003000070b00000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000003000000b00000000000000000000000000000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000000000000ccc70003000000b00000000000000000000000000000000d000000c00000000
d000000c00000000001011010000000000000000000000000000000000000000cccccc003000000b00000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000cffffc003000000b00000000000000000000000000000000d000000c00000000
5111111100000000000000000000000000000000000000000000000000000000c5ff5c0011111111000000000000000000000000000000005111111100000000
dccccc7700000000dccccc770000000000000000008888000000000000000000cffffc000000000000000000000000000cccccc000000000dccccc7700000000
d000007700000000d0000077000000000000000018888880000000000000000cccccccc0000000000000000000000000d000007c00000000d000007700000000
d000000c00000000d000000c0000000000000000288888880000000000000000cccccc00000000000000000000000000d000770c00000000d000000c00000000
d000000c00000000d000000c00000000000000002e8e8e8e0000000000000000c0000c00000000000000000000000000d000770c00000000d000000c00000000
d000000c00000000d000000c00000000000000002e8e8e8e000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c00000000d000000c000000000000000022888888000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c00000000d000000c000000000000000002288880000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
51111111000000005111111100000000000000000022220000000000000000000000000000000000000000000000000001111110000000005111111100000000
dccccc770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dccccc7700000000dccccc7700000000
d00000770000000000000000000000000000000000000000101110100000000000000000000000000000000000000000d000007700000000d000007700000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000001011010000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000d000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000a0000a000000000000000000000000051111111000000005111111100000000
dccccc7700000000000000000000000000000000000000000000000000000000a000770a000000003bbbbbb700000000dccccc77000000000cccccc000000000
d000007700000000000000000000000000000000000000000000000000000000a000770a101110103000000b00000000d000007700000000d000007c00000000
d000000c00000000000000000000000000000000000000000000000000000000a000000a000000003000070b00000000d000000c00000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000a000000a000000003000000b00000000d000000c00000000d000770c00000000
d000000c000000000000000000000000000000000000000000000000000000000a0000a0000000003000000b00000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000aaaa00001011013000000b00000000d000000c00000000d000000c00000000
d000000c0000000000000000000000000000000000000000000000000000000000000000000000003000000b00000000d000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000111111110000000051111111000000000111111000000000
0cccccc00000000000000000dccccc77dccccc77dccccc770000000000000000000000003bbbbbb73bbbbbb7000000000000000000000000dccccc7700000000
d000007c1011101000000000d0000077d0000077d00000770000000000000000000000003000000b3000000b000000000000000000000000d000007700000000
d000770c0000000000000000d000000cd000000cd000000c0000000000000000000000003000070b3000070b000000000000000000000000d000000c00000000
d000770c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0010110100000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c0000000000000000000000003000000b3000000b000000000000000000000000d000000c00000000
01111110000000000000000051111111511111115111111100000000000000000000000011111111111111110000000000000000000000005111111100000000
dccccc770000000000000000dccccc77dccccc77dccccc77000000000000000000000000000000000000000000000000dccccc7700000000dccccc7700000000
d00000770000000000000000d0000077d0000077d0000077000000000000000000000000101110100000000000000000d000007700000000d000007700000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000001011010000000000000000d000000c00000000d000000c00000000
d000000c0000000000000000d000000cd000000cd000000c000000000000000000000000000000000000000000000000d000000c00000000d000000c00000000
51111111000000000000000051111111511111115111111100000000000000000000000000000000000000000000000051111111000000005111111100000000
dccccc77000000000000000000000000000000000000000000000000dccccc77dccccc77dccccc77dccccc77dccccc77dccccc7700000000dccccc7700000000
d0000077000000000000000000000000000000000000000000000000d0000077d0000077d0000077d0000077d0000077d000007710111010d000007700000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00101101d000000c00000000
d000000c000000000000000000000000000000000000000000000000d000000cd000000cd000000cd000000cd000000cd000000c00000000d000000c00000000
51111111000000000000000000000000000000000000000000000000511111115111111151111111511111115111111151111111000000005111111100000000
dccccc77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000
d000007700000000000000001011101000000000000000000000000000000000000000000000000000000000000000000000000000000000d000007c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000770c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000010110100000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
d000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000c00000000
51111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111000000000
0cccccc0dccccc77dccccc77dccccc77dccccc770cccccc0dccccc77dccccc77dccccc77dccccc77dccccc77dccccc77dccccc770cccccc0dccccc7700000000
d000007cd0000077d0000077d0000077d0000077d000007cd0000077d0000077d0000077d0000077d0000077d0000077d0000077d000007cd000007700000000
d000770cd000000cd000000cd000000cd000000cd000770cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000770cd000000c00000000
d000770cd000000cd000000cd000000cd000000cd000770cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000770cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
d000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000cd000000c00000000
01111110511111115111111151111111511111110111111051111111511111115111111151111111511111115111111151111111011111105111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700000770077000000707077707770700000000000000000000000000000007070000077700000707070707770777000000000000000000000000000000000
70700000070007000000707070007070700000000000000000000000000000007070000000700000707070707070707000000000000000000000000000000000
07000000070007000000777077707070777000000000000000000000000000007770000007700000777077707770777000000000000000000000000000000000
70700000070007000000007000707070707000000000000000000000000000000070000000700000007000700070707000000000000000000000000000000000
70700000777077700700007077707770777000000000000000000000000000007770000077700700007000700070777000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0002020200000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3d2929292929292929292929292929292929292929292929292929292929290000000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d004142434445464748494a0000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414141414140d1e1e3d3d00290000002929292929292929000000250000002500000025000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d1414141414140d1e1438291414143d3d00000000000000000000000000283d29292929292929292929292929003d0000006364656766006a696b00003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414141414141414143d3d00282900000000000000000000283d00270027002700270027002700003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d140d1e0e141f1f141414141414293d3d00002700000000000000000000283d00000000000000000000000000003d00000071720074656771756471003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141f1f141414141414143d3d00000028290000000000000000283d00000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414141438291414143d3d00000000000000000029000000283d00292929292929292929292929293d0000717478007172007a7b7c00003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d36141414141414141414141414143d3d00000000000000000027290000283d00000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d29291414141414141414141414143d3d00000000000000000000000000283d00000000000000000000000000003d007a7b715c005d656666000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d37371414141414141414141414143d3d00000000000000000000000000283d00000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414140b14382914143d3d00000000000000000000002829283d29292929292929292929292929003d000000005e6575715c66000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414141b140b1414143d3d00000029000029000029000000283d00000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d14141414141414142b141b3829143d3d00000000000000000000000000283d00000000000000000000000000003d00000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d35353535353535143b142b1414143d3d25252525252525252525252525253d00000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020202020202020202020202020202020229292929292929292929292929293d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d292929292929292929292929292929290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000002929292929292929292929292929292929292929292929292929292929292929292929292929000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000250000250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000002929252929292900000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c55012540075100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100003073020750217201171000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400002a3602e350313300030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
