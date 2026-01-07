/*
 * Surface-Stable Fractal Dithering - Sky Basic Fragment Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Fragment shader for basic sky with cylindrical UV dithering
 *              Uses cylindrical projection near horizon for seamless terrain transition
 */

#version 120

// ============================================================================
// SHADER OPTIONS
// ============================================================================

#define DITHER_DOT_SCALE 5.0 // [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
#define DITHER_SIZE_VARIABILITY 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define DITHER_DOT_CONTRAST 1.0 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 3.0 5.0]
#define DITHER_STRETCH_SMOOTH 1.0 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define DITHER_EXPOSURE 1.0 // [0.2 0.4 0.6 0.8 1.0 1.5 2.0 2.5 3.0 4.0 5.0]
#define DITHER_OFFSET 0.0 // [-1.0 -0.8 -0.6 -0.4 -0.2 0.0 0.2 0.4 0.6 0.8 1.0]
#define DITHER_COLOR_MODE 0 // [0 1 2]

//#define DITHER_INVERSE_DOTS
//#define DITHER_RADIAL_COMP
//#define DITHER_QUANTIZE_LAYERS
//#define DITHER_DEBUG_FRACTAL

// ============================================================================
// INCLUDES
// ============================================================================

#include "lib/dither3d_color.glsl"

// ============================================================================
// VARYINGS
// ============================================================================

varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 viewDir;

// ============================================================================
// CONSTANTS
// ============================================================================

const float PI = 3.14159265359;
const float INV_PI = 0.31830988618;

// ============================================================================
// SKY UV CALCULATION
// ============================================================================

/**
 * Cylindrical sky UV that matches terrain-like projection near horizon
 * This creates a seamless transition between sky and terrain
 */
vec2 getCylindricalSkyUV(vec3 dir) {
    // Normalize direction in XZ plane
    vec2 dirXZ = normalize(dir.xz);
    
    // Horizontal angle (azimuth) - continuous around 360°
    float u = atan(dirXZ.x, dirXZ.y) * INV_PI;  // [-1, 1]
    
    // Vertical: Use actual Y direction, scaled to simulate distant terrain
    // At horizon (y=0), this matches terrain projection
    // Higher up, it gradually diverges but that's far from terrain anyway
    float v = dir.y * 4.0;  // Scale factor to match terrain UV density
    
    return vec2(u, v);
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
    vec3 dir = normalize(viewDir);
    
    // Primary UV: cylindrical projection
    vec2 skyUV = getCylindricalSkyUV(dir);
    
    // Alternative UV for seam handling (rotated 180°)
    vec2 skyUVAlt = getCylindricalSkyUV(vec3(-dir.x, dir.y, -dir.z));
    
    // Get derivatives and choose smaller ones to avoid seam artifacts
    vec2 dxA = dFdx(skyUV);
    vec2 dyA = dFdy(skyUV);
    vec2 dxB = dFdx(skyUVAlt);
    vec2 dyB = dFdy(skyUVAlt);
    
    vec2 dx = (dot(dxA, dxA) < dot(dxB, dxB)) ? dxA : dxB;
    vec2 dy = (dot(dyA, dyA) < dot(dyB, dyB)) ? dyA : dyB;
    
    // Apply exposure and offset
    vec3 skyColor = clamp(glcolor.rgb * DITHER_EXPOSURE + DITHER_OFFSET, 0.0, 1.0);
    
    // Apply dithering based on color mode
    #if DITHER_COLOR_MODE == 0
        float luma = 0.299 * skyColor.r + 0.587 * skyColor.g + 0.114 * skyColor.b;
        float dithered = getDither3D(skyUV, screenPos, dx, dy, luma).x;
        vec3 result = vec3(dithered);
    #elif DITHER_COLOR_MODE == 1
        float r = getDither3D(skyUV, screenPos, dx, dy, skyColor.r).x;
        float g = getDither3D(skyUV + vec2(0.1, 0.07), screenPos, dx, dy, skyColor.g).x;
        float b = getDither3D(skyUV + vec2(0.2, 0.14), screenPos, dx, dy, skyColor.b).x;
        vec3 result = vec3(r, g, b);
    #else
        vec3 result = applyDither3DColor(skyUV, screenPos, dx, dy, skyColor);
    #endif
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(result, 1.0);
}
