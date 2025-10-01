#version 330 core
out vec4 FragColor;
in vec2 fragTexCoord;

uniform sampler2D diffuse;

void main()
{
    FragColor = vec4(texture(diffuse, fragTexCoord).r, 0, 0, 1);
}
