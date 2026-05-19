// extern number scaleFactor;  // 1.0 = normal size, <1 shrinks
extern number desatAmount;  // 0.0 = full color, 1.0 = grayscale

vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
{
    vec4 pixel = Texel(tex, texCoord) * color;

    // Convert to grayscale using luminance weights
    float gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));

    // Mix between original color and grayscale
    pixel.rgb = mix(pixel.rgb, vec3(gray), desatAmount);

    // Apply scale (handled in Lua via love.graphics.scale)
    return pixel;
}
