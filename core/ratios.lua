function BallSize(wheelSize)
    return wheelSize * 2
end

function FrontWheelMass(rearWheelMass)
    return 0 --rearWheelMass / 16
end

function FrontWheelGravityScale(rearWheelGravityScale)
    return 0 --rearWheelGravityScale / 12
end

function FrontWheelTorque(rearWheelForce)
    return rearWheelForce * 2 --  3.5
end