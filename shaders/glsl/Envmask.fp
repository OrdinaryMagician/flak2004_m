// basic texture + masked equirectangular envmap + gradient rim
// allows for up to three different layers of environment mapping (RGB mask)
#define RECIPROCAL_PI2 0.15915494

#ifndef RIMSTEP
#define RIMSTEP .5
#endif
#ifndef ENVFACT
#define ENVFACT 1.
#endif
#ifndef RIMFACT
#define RIMFACT 1.
#endif

#ifndef RIMSTEP2
#define RIMSTEP2 .5
#endif
#ifndef ENVFACT2
#define ENVFACT2 1.
#endif
#ifndef RIMFACT2
#define RIMFACT2 1.
#endif

#ifndef RIMSTEP3
#define RIMSTEP3 .5
#endif
#ifndef ENVFACT3
#define ENVFACT3 1.
#endif
#ifndef RIMFACT3
#define RIMFACT3 1.
#endif

void SetupMaterial( inout Material mat )
{
	vec4 base = getTexel(vTexCoord.st);
	vec4 mask = texture(masktex,vTexCoord.st);
	vec3 norm = normalize(vWorldNormal.xyz);
	vec3 eye = normalize(uCameraPos.xyz-pixelpos.xyz);
	vec3 rvec = normalize(reflect(eye,norm));
	vec2 uv = vec2(atan(rvec.z,rvec.x)*RECIPROCAL_PI2+.5,asin(rvec.y)*RECIPROCAL_PI2+.5);
	vec2 uv2 = vec2(atan(rvec.z,abs(rvec.x))*RECIPROCAL_PI2+.5,asin(rvec.y)*RECIPROCAL_PI2+.5);
	vec2 dTdx = dFdx(uv2);
	vec2 dTdy = dFdy(uv2);
	float rf = 1.-abs(dot(eye,norm));
	vec3 envcol = textureGrad(envtex,uv,dTdx,dTdy).rgb*ENVFACT;
#ifdef RIM_LIGHTING
	float rim = smoothstep(RIMSTEP,1.,rf);
	vec3 rimcol = texture(rimtex,vec2(.25+.5*rim,.5)).rgb;
	envcol = mix(envcol,rimcol,rim*RIMFACT);
#endif
	mat.Base = vec4(base.rgb+envcol*mask.x,base.a);
#if defined(ENV_TWOLAYER) || defined(ENV_THREELAYER)
	envcol = textureGrad(envtex2,uv,dTdx,dTdy).rgb*ENVFACT2;
#ifdef RIM_LIGHTING
	rim = smoothstep(RIMSTEP2,1.,rf);
	rimcol = texture(rimtex2,vec2(.25+.5*rim,.5)).rgb;
	envcol = mix(envcol,rimcol,rim*RIMFACT2);
#endif
	mat.Base.rgb += envcol*mask.y;
#endif
#if defined(ENV_THREELAYER)
	envcol = textureGrad(envtex3,uv,dTdx,dTdy).rgb*ENVFACT3;
#ifdef RIM_LIGHTING
	rim = smoothstep(RIMSTEP3,1.,rf);
	rimcol = texture(rimtex3,vec2(.25+.5*rim,.5)).rgb;
	envcol = mix(envcol,rimcol,rim*RIMFACT3);
#endif
	mat.Base.rgb += envcol*mask.z;
#endif
	mat.Normal = ApplyNormalMap(vTexCoord.st);
	if ( (uTextureMode&TEXF_Brightmap) != 0 )
		mat.Bright = texture(brighttexture,vTexCoord.st);
}
