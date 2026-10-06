uniform vec3 tint;

void main() {
    float d = length(v_uv - vec2(0.5));
    float alpha = smoothstep(0.55, 0.08, d) * 0.22 * u_progress;
    fragColor = vec4(tint * alpha, alpha);
}
