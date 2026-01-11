/*
 * Surface-Stable Fractal Dithering - Sky Textured Vertex Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 screenPos;

void main() {
    gl_Position = ftransform();
    screenPos = gl_Position;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
