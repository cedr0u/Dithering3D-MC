/*
 * Surface-Stable Fractal Dithering - Sky Basic Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 * Uses cylindrical projection near horizon for seamless terrain transition
 */

#version 120

#include "lib/dither3d_options.glsl"
#include "lib/dither3d_color.glsl"

varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 viewDir;

// Cylindrical sky UV for seamless terrain transition
vec2 getCylindricalSkyUV(vec3 dir) {
    vec2 dirXZ = normalize(dir.xz);
    float u = atan(dirXZ.x, dirXZ.y) * INV_PI;
    float v = dir.y * 4.0;
    return vec2(u, v);
}

void main() {
    vec3 dir = normalize(viewDir);
    
    // Primary and alternative UV for seam handling
    vec2 skyUV = getCylindricalSkyUV(dir);
    vec2 skyUVAlt = getCylindricalSkyUV(vec3(-dir.x, dir.y, -dir.z));
    
    // Choose smaller derivatives to avoid seam artifacts
    vec2 dxA = dFdx(skyUV), dyA = dFdy(skyUV);
    vec2 dxB = dFdx(skyUVAlt), dyB = dFdy(skyUVAlt);
    vec2 dx = (dot(dxA, dxA) < dot(dxB, dxB)) ? dxA : dxB;
    vec2 dy = (dot(dyA, dyA) < dot(dyB, dyB)) ? dyA : dyB;
    
    vec3 skyColor = clamp(glcolor.rgb * DITHER_EXPOSURE + DITHER_OFFSET, 0.0, 1.0);
    vec3 result = applyDither3DColor(skyUV, screenPos, dx, dy, skyColor);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(result, 1.0);
}
