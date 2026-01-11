/*
 * Surface-Stable Fractal Dithering - Composite Fragment Shader
 * Copyright (c) 2025 Cedric - MPL-2.0
 */

#version 120

uniform sampler2D colortex0;

varying vec2 texcoord;

void main() {
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(texture2D(colortex0, texcoord).rgb, 1.0);
}
