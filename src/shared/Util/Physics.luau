--!strict
local physics = {}

function physics.CalculatePosition(initialPosition: Vector3, velocity: Vector3, acceleration: Vector3, dt: number): Vector3
    return initialPosition + velocity * dt + 0.5 * acceleration * dt * dt
end

function physics.CalculateVelocity(initialVelocity: Vector3, acceleration: Vector3, dt: number): Vector3
    return initialVelocity + acceleration * dt
end

return physics