/*
 * Surface-Stable Fractal Dithering - Composite Vertex Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

varying vec2 texcoord;

void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
