import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const xaiApiKey = Deno.env.get("XAI_API_KEY");

    if (!xaiApiKey) {
      return new Response(
        JSON.stringify({ error: "XAI_API_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { image_base64, style_key } = await req.json();

    if (!image_base64 || !style_key) {
      return new Response(
        JSON.stringify({ error: "Missing image_base64 or style_key" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: promptRow, error: promptError } = await supabase
      .from("edit_style_prompts")
      .select("prompt_template")
      .eq("style_key", style_key)
      .eq("is_active", true)
      .single();

    if (promptError || !promptRow) {
      return new Response(
        JSON.stringify({ error: `Style '${style_key}' not found or inactive` }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const xaiResponse = await fetch("https://api.x.ai/v1/images/edits", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${xaiApiKey}`,
      },
      body: JSON.stringify({
        model: "grok-imagine-image",
        prompt: promptRow.prompt_template,
        image: {
          url: `data:image/jpeg;base64,${image_base64}`,
          type: "image_url",
        },
        n: 1,
        response_format: "b64_json",
      }),
    });

    if (!xaiResponse.ok) {
      const errorBody = await xaiResponse.text();
      console.error("xAI API error:", xaiResponse.status, errorBody);
      return new Response(
        JSON.stringify({ error: "Image generation failed", details: errorBody }),
        { status: xaiResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const xaiResult = await xaiResponse.json();
    const generatedImage = xaiResult.data?.[0]?.b64_json;

    if (!generatedImage) {
      return new Response(
        JSON.stringify({ error: "No image returned from xAI" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ image_base64: generatedImage }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
