/*
 * Surface-Stable Fractal Dithering - Hand Vertex Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec4 screenPos;
varying vec3 worldPos;
varying vec3 worldNormal;

void main() {
    gl_Position = ftransform();
    screenPos = gl_Position;
    
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPosH = gbufferModelViewInverse * viewPos;
    worldPos = worldPosH.xyz + cameraPosition;
    
    vec3 viewNormal = gl_NormalMatrix * gl_Normal;
    worldNormal = mat3(gbufferModelViewInverse) * viewNormal;
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
}
