/*
 * Surface-Stable Fractal Dithering - Clouds Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

#include "lib/dither3d_options.glsl"
#include "lib/dither3d_color.glsl"

varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 worldPos;

void main() {
    // XZ plane for horizontal clouds
    vec2 surfaceUV = worldPos.xz * 0.1;
    vec3 dithered = applyDither3DColorSimple(surfaceUV, screenPos, glcolor.rgb);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, glcolor.a);
}
