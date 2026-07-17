#pragma once
#include <vector>

// ISteamUtils helper bindings. Currently only the image (achievement icon) accessors
// are exposed, since ISteamUserStats::GetAchievementIcon() returns an image handle
// that must be read through ISteamUtils::GetImageRGBA().
struct xSteamUtils
{
    // steam.SteamUtils.GetImageSize(iImage) -> ok, width, height
    static int GetImageSize(lua_State* L)
    {
        const int iImage = (int)luaL_checkinteger(L, 1);
        uint32 nWidth = 0;
        uint32 nHeight = 0;
        const bool ret = SteamUtils()->GetImageSize(iImage, &nWidth, &nHeight);
        lua_pushboolean(L, ret);
        lua_push_uint32(L, nWidth);
        lua_push_uint32(L, nHeight);
        return 3;
    };

    // steam.SteamUtils.GetImageRGBA(iImage) -> dataString, width, height
    // dataString is raw RGBA bytes (4*w*h). Returns nil, nil, nil on failure.
    static int GetImageRGBA(lua_State* L)
    {
        const int iImage = (int)luaL_checkinteger(L, 1);
        uint32 nWidth = 0;
        uint32 nHeight = 0;
        if (!SteamUtils()->GetImageSize(iImage, &nWidth, &nHeight) || nWidth == 0 || nHeight == 0)
        {
            lua_pushnil(L); lua_pushnil(L); lua_pushnil(L);
            return 3;
        }
        const size_t nBufferSize = (size_t)4 * (size_t)nWidth * (size_t)nHeight;
        std::vector<uint8> buf(nBufferSize);
        if (!SteamUtils()->GetImageRGBA(iImage, buf.data(), (int)nBufferSize))
        {
            lua_pushnil(L); lua_pushnil(L); lua_pushnil(L);
            return 3;
        }
        lua_pushlstring(L, (const char*)buf.data(), nBufferSize); // RGBA bytes
        lua_push_uint32(L, nWidth);
        lua_push_uint32(L, nHeight);
        return 3;
    };

    static int xRegister(lua_State* L)
    {
        static const luaL_Reg lib[] = {
            xfbinding(GetImageSize),
            xfbinding(GetImageRGBA),
            {NULL, NULL},
        };
        lua_pushstring(L, "SteamUtils");
        lua_createtable(L, 0, 2);
        luaL_register(L, NULL, lib);
        lua_settable(L, -3);
        return 0;
    };
};
