function BallSize(wheelSize)
    return wheelSize * 2
end

function FrontWheelMass(rearWheelMass)
    return rearWheelMass / 6
end

function FrontWheelGravityScale(rearWheelGravityScale)
    return rearWheelGravityScale / 3
end

function FrontWheelTorque(rearWheelForce)
    return rearWheelForce * 2 --  3.5
end