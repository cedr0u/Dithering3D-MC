/*
 * Surface-Stable Fractal Dithering - Beacon Beam Fragment Shader
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
    vec3 color = albedo.rgb * glcolor.rgb;
    
    vec2 surfaceUV = worldPos.xz + vec2(worldPos.y * 0.1, worldPos.y * 0.1);
    vec3 dithered = applyDither3DColorSimple(surfaceUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, albedo.a * glcolor.a);
}
