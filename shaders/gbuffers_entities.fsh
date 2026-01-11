/*
 * Surface-Stable Fractal Dithering - Entities Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

#include "lib/dither3d_options.glsl"
#include "lib/dither3d_color.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 worldPos;
varying vec3 worldNormal;

void main() {
    vec4 albedo = texture2D(texture, texcoord);
    if (albedo.a < 0.1) discard;
    
    vec4 light = texture2D(lightmap, lmcoord);
    vec3 color = albedo.rgb * glcolor.rgb * light.rgb;
    
    vec2 surfaceUV = getTriplanarUV(worldPos, worldNormal);
    vec3 dithered = applyDither3DColorSimple(surfaceUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, albedo.a);
}
