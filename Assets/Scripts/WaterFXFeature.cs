using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class WaterFXFeature : ScriptableRendererFeature
{
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(waterFXPass);
    }

    public override void Create()
    {
        waterFXPass = new WaterFXPass();
        waterFXPass.renderPassEvent = RenderPassEvent.AfterRenderingPrePasses;
    }

    WaterFXPass waterFXPass;

    private class WaterFXPass : ScriptableRenderPass
    {
        static int WaterMaskID = Shader.PropertyToID("_WaterFXTexture");
        static RenderTargetIdentifier WaterMask_idt = new RenderTargetIdentifier(WaterMaskID);
        ShaderTagId waterMask_stid = new ShaderTagId("WaterFX");
        Color m_clearColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            cmd.GetTemporaryRT(WaterMaskID, new RenderTextureDescriptor(Screen.width / 2, Screen.height / 2, RenderTextureFormat.Default, 0),FilterMode.Bilinear);
            ConfigureTarget(WaterMask_idt);
            ConfigureClear(ClearFlag.Color, m_clearColor);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("RenderWaterFXTexture");
            var drawSetting = CreateDrawingSettings(waterMask_stid, ref renderingData, SortingCriteria.CommonTransparent);
            var filterSetting = new FilteringSettings(RenderQueueRange.all);
            context.DrawRenderers(renderingData.cullResults, ref drawSetting, ref filterSetting);
            cmd.SetGlobalTexture(WaterMaskID, WaterMask_idt);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(WaterMaskID);
        }
    }
}
