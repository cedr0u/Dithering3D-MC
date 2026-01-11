/*
 * Surface-Stable Fractal Dithering - Spider Eyes Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

#include "lib/dither3d_options.glsl"
#include "lib/dither3d_color.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 worldPos;

void main() {
    vec4 albedo = texture2D(texture, texcoord);
    if (albedo.a < 0.1) discard;
    
    vec3 color = albedo.rgb * glcolor.rgb;
    
    vec2 surfaceUV = getSimpleWorldUV(worldPos);
    vec3 dithered = applyDither3DColorSimple(surfaceUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, albedo.a * glcolor.a);
}
