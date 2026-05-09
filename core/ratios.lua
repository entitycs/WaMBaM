function BallSize(wheelSize)
    return wheelSize * 2
end

function FrontWheelMass(rearWheelMass)
    return rearWheelMass / 4
end

function FrontWheelGravityScale(rearWheelGravityScale)
    return rearWheelGravityScale / 3
end

function FrontWheelTorque(rearWheelTorque)
    return rearWheelTorque * 3.5
end