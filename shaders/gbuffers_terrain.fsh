/*
 * Surface-Stable Fractal Dithering - Terrain Fragment Shader
 * 
 * Copyright (c) 2025 Cedric
 * Based on Dither3D by Rune Skovbo Johansen
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Description: Fragment shader for terrain rendering with dithering
 *              Uses triplanar projection for proper surface-stable dithering
 */

#version 120

// ============================================================================
// SHADER OPTIONS (Iris/OptiFine parsed from main shader files)
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
// UNIFORMS
// ============================================================================

uniform sampler2D texture;       // Terrain texture atlas (gtexture)
uniform sampler2D lightmap;      // Minecraft lightmap

// ============================================================================
// VARYINGS (from vertex shader)
// ============================================================================

varying vec2 texcoord;           // Texture coordinates
varying vec2 lmcoord;            // Lightmap coordinates
varying vec4 glcolor;            // Vertex color
varying vec4 screenPos;          // Screen-space position (clip space)
varying vec3 worldPos;           // World position for surface-stable dithering
varying vec3 worldNormal;        // World-space normal for triplanar projection

// ============================================================================
// TRIPLANAR UV PROJECTION
// ============================================================================

/**
 * Compute surface-stable UV using triplanar projection
 * Automatically selects the best projection plane based on surface normal
 */
vec2 getTriplanarUV(vec3 pos, vec3 normal) {
    // Get absolute normal for blending weights
    vec3 blend = abs(normalize(normal));
    
    // Sharpen the blend to prefer dominant axis
    blend = pow(blend, vec3(4.0));
    blend = blend / (blend.x + blend.y + blend.z + 0.0001);
    
    // Project position onto each plane
    vec2 uvX = pos.yz;  // YZ plane (east/west walls)
    vec2 uvY = pos.xz;  // XZ plane (floors/ceilings) 
    vec2 uvZ = pos.xy;  // XY plane (north/south walls)
    
    // Blend based on normal direction
    return uvX * blend.x + uvY * blend.y + uvZ * blend.z;
}

// ============================================================================
// MAIN
// ============================================================================

void main() {
    // Sample terrain texture
    vec4 albedo = texture2D(texture, texcoord);
    
    // Alpha test (for cutout blocks like leaves, grass)
    if (albedo.a < 0.1) discard;
    
    // Sample lightmap for Minecraft lighting
    vec4 light = texture2D(lightmap, lmcoord);
    
    // Calculate final lit color
    vec3 color = albedo.rgb * glcolor.rgb * light.rgb;
    
    // ========================================================================
    // Surface-stable UV calculation using triplanar projection
    // This ensures dither pattern "sticks" to all surface orientations
    // ========================================================================
    vec2 surfaceUV = getTriplanarUV(worldPos, worldNormal);
    
    // Apply dithering to the lit color
    vec3 dithered = applyDither3DColorSimple(surfaceUV, screenPos, color);
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(dithered, albedo.a);
}
