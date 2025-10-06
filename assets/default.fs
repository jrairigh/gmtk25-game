#version 330 core
out vec4 FragColor;
in vec2 fragTexCoord;

uniform sampler2D diffuse;

void main()
{
    FragColor = texture(diffuse, fragTexCoord);
}
