/*
 * Surface-Stable Fractal Dithering - Terrain Vertex Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

// ============================================================================
// UNIFORMS
// ============================================================================

uniform mat4 gbufferModelViewInverse;    // Inverse model-view
uniform vec3 cameraPosition;             // Camera position in world space

// ============================================================================
// VARYINGS (output to fragment shader)
// ============================================================================

varying vec2 texcoord;           // Texture coordinates
varying vec2 lmcoord;            // Lightmap coordinates
varying vec4 glcolor;            // Vertex color (biome coloring, etc.)
varying vec4 screenPos;          // Screen-space position (for radial comp)
varying vec3 worldPos;           // World position for surface-stable dithering
varying vec3 worldNormal;        // World-space normal for triplanar projection

// ============================================================================
// MAIN
// ============================================================================

void main() {
    // Model-view-projection transformation
    gl_Position = ftransform();
    
    // Store screen position for radial compensation
    screenPos = gl_Position;
    
    // Calculate world position for surface-stable dithering
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPosH = gbufferModelViewInverse * viewPos;
    worldPos = worldPosH.xyz + cameraPosition;
    
    // Transform normal to world space
    vec3 viewNormal = gl_NormalMatrix * gl_Normal;
    worldNormal = mat3(gbufferModelViewInverse) * viewNormal;
    
    // Texture coordinates (atlas)
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    // Lightmap coordinates
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    
    // Vertex color (biome tinting, AO)
    glcolor = gl_Color;
}
