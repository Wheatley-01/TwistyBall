export type ball = {
    ServerBall: MeshPart,
    Target: Model,

}

local ballData = {
    HeightOffset = 6,
    InitialVelocity = 7,
    Acceleration = 15,
    DeflectVelocity = 20,

    DeflectTime = 1,
    DeflectToNormalTime = 0.2,
    CooldownTime = 3,
}

return ballData