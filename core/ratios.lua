function BallSize(wheelSize)
    return wheelSize * 2
end

function FrontWheelMass(rearWheelMass)
    return  1
end

function FrontWheelGravityScale(rearWheelGravityScale)
    return 0 --rearWheelGravityScale / 12
end

function FrontWheelTorque(rearWheelForce)
    return rearWheelForce *  1--3
end