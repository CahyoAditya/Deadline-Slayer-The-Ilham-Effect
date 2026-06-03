shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture,filter_linear;
// 鱼眼效果强度控制
uniform float fish_intensity : hint_range(0.0, 2.0) = 1.0;
void fragment() {
    // 获取屏幕分辨率
    vec2 iResolution = vec2(textureSize(SCREEN_TEXTURE, 0));
    // 基础UV坐标（适配Godot坐标系）
    vec2 uv = UV;
    uv.y = 1.0 - uv.y; // 翻转Y轴

    // 宽高比计算
    float aspectRatio = iResolution.x / iResolution.y;

    // 计算强度参数
    float strength = fish_intensity * 0.03;
    vec2 intensity = vec2(
        strength * aspectRatio,
        strength * aspectRatio
    );

    // 坐标转换到[-1, 1]范围
    vec2 coords = uv;
    coords = (coords - 0.5) * 2.0;

    // 计算坐标偏移量
    vec2 realCoordOffs;
    realCoordOffs.x = (1.0 - coords.y * coords.y) * intensity.y * coords.x;
    realCoordOffs.y = (1.0 - coords.x * coords.x) * intensity.x * coords.y;

    // 应用偏移
    vec2 fuv = uv - realCoordOffs;
    // 边界检查
    if(fuv.x < 0.0 || fuv.x > 1.0 || fuv.y < 0.0 || fuv.y > 1.0) {
        COLOR = vec4(0.0); // 超出范围显示黑
		vec4 color = texture(SCREEN_TEXTURE,fuv);
		COLOR.rgb=mix(color.rgb,color.bgr,length(fuv-0.5));
    } else {
        // 采样时再次翻转Y轴适配Godot坐标系
        fuv.y = 1.0 - fuv.y;
        COLOR = texture(SCREEN_TEXTURE, fuv);
		vec4 color = texture(SCREEN_TEXTURE,fuv);
		COLOR.rgb=mix(color.rgb,color.bgr,length(fuv-0.5));
    }
}