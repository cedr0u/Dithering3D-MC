/*
 * Surface-Stable Fractal Dithering - Sky Textured Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

#include "lib/dither3d_options.glsl"
#include "lib/dither3d_color.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;

void main() {
    vec4 texColor = texture2D(texture, texcoord);
    vec3 color = texColor.rgb * glcolor.rgb;
    
    // Scaled texture UV for consistent dithering
    vec2 ditherUV = texcoord * 4.0;
    vec3 dithered = applyDither3DColorSimple(ditherUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, texColor.a * glcolor.a);
}
