using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class GenTilemapData : Editor
{
    [MenuItem("Tools/GenTilemapData")]
    public static void Gen()
    {
        // 地图尺寸
        float size = 32;
        Texture2D texture = new Texture2D((int)size, (int)size, TextureFormat.RGBA32, false, false);

        // 对应的四个采样 Tile 块的 Uv
        Vector2[] tilemapGroup = new Vector2[4];
        tilemapGroup[0] = new Vector2(0, 0);
        tilemapGroup[1] = new Vector2(0.5f, 0);
        tilemapGroup[2] = new Vector2(0.5f, 0.5f);
        tilemapGroup[3] = new Vector2(0, 0.5f);

        Color color = Color.white;
        for (int i = 0; i < texture.width; i++)
        {
            for (int j = 0; j < texture.height; j++)
            {
                // 计算像素左下角 uv = rg
                color.r = i / size;
                color.g = j / size;

                // 随机取一个 tile
                var index = Random.Range(0, 4);
                var uv = tilemapGroup[index];

                // 赋值
                color.b = uv.x;
                color.a = uv.y;

                // 把像素写入贴图
                texture.SetPixel(i, j, color);
            }
        }
        texture.Apply();

        var bytes = texture.EncodeToTGA();

        var fs = File.Create(Application.dataPath + "/Texs/tilemap_data.tga");
        fs.Write(bytes, 0, bytes.Length);
        fs.Close();

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
