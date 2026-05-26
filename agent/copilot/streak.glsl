extern float angularVel;     // radians per second (signed)
extern float threshold;      // minimum abs(angularVel) before effect starts
extern float streakStrength; // how long the streaks stretch

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 sc)
{
    vec4 base = Texel(tex, uv) * color;

    // Compute spin factor
    float speed = abs(angularVel);
    float f = clamp((speed - threshold) / threshold, 0.0, 1.0);

    if (f <= 0.0) {
        return base; // no streaks
    }

    // UV center for circle sprites
    vec2 center = vec2(0.5, 0.5);
    vec2 dir = uv - center;

    // Tangent direction = perpendicular to radius
    vec2 tangent = normalize(vec2(-dir.y, dir.x));

    // Signed direction based on rotation direction
    tangent *= sign(angularVel);

    // Accumulate streak samples
    vec4 streak = vec4(0.0);
    const int samples = 6;

    for (int i = 0; i < samples; i++) {
        float t = float(i) / float(samples - 1);
        vec2 offset = uv - tangent * t * streakStrength * f;
        vec4 s = Texel(tex, offset);
        streak += s * s.a;   // weight by alpha
        // streak += Texel(tex, offset);
    }

    streak /= float(samples);

    // Blend streaks with base color
    return mix(base, streak, f);
}
