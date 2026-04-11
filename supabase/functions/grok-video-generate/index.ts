import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

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
    const xaiApiKey = Deno.env.get("XAI_API_KEY");

    if (!xaiApiKey) {
      return new Response(
        JSON.stringify({ error: "XAI_API_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (req.method === "POST") {
      const body = await req.json();
      const { image_base64, image_url, prompt, duration, resolution } = body;

      const imageSource = image_base64
        ? `data:image/jpeg;base64,${image_base64}`
        : image_url;

      if (!imageSource) {
        return new Response(
          JSON.stringify({ error: "Missing image_base64 or image_url" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log(`Image source type: ${image_base64 ? "base64" : "url"}`);
      if (prompt) {
        console.log(`Prompt: ${prompt.substring(0, 100)}`);
      }

      const requestBody: Record<string, unknown> = {
        model: "grok-imagine-video",
        image: {
          url: imageSource,
        },
        duration: duration || 6,
        aspect_ratio: "9:16",
        resolution: resolution || "720p",
      };

      if (prompt && prompt.trim().length > 0) {
        requestBody.prompt = prompt;
      } else {
        requestBody.prompt = "Subtle cinematic motion. Gentle camera movement with parallax depth. Soft atmospheric effects like light rays or particles drifting. Keep the composition faithful to the original image.";
      }

      console.log("Sending request to xAI video generation...");

      const xaiResponse = await fetch("https://api.x.ai/v1/videos/generations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${xaiApiKey}`,
        },
        body: JSON.stringify(requestBody),
      });

      if (!xaiResponse.ok) {
        const errorBody = await xaiResponse.text();
        console.error("xAI video generation error:", xaiResponse.status, errorBody);
        return new Response(
          JSON.stringify({ error: `xAI error (${xaiResponse.status})`, details: errorBody }),
          { status: xaiResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const result = await xaiResponse.json();
      console.log("xAI response:", JSON.stringify(result));

      return new Response(
        JSON.stringify({ request_id: result.request_id }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (req.method === "GET") {
      const url = new URL(req.url);
      const requestId = url.searchParams.get("request_id");

      if (!requestId) {
        return new Response(
          JSON.stringify({ error: "Missing request_id" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const xaiResponse = await fetch(`https://api.x.ai/v1/videos/${requestId}`, {
        headers: {
          "Authorization": `Bearer ${xaiApiKey}`,
        },
      });

      if (!xaiResponse.ok) {
        const errorBody = await xaiResponse.text();
        console.error("xAI video poll error:", xaiResponse.status, errorBody);
        return new Response(
          JSON.stringify({ error: "Failed to check video status", details: errorBody }),
          { status: xaiResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const result = await xaiResponse.json();

      const response: Record<string, string> = {
        status: result.status || "pending",
        video_url: "",
        error: "",
      };

      if (result.status === "done" && result.video && result.video.url) {
        response.video_url = result.video.url;
      }

      if (result.error) {
        response.error = result.error.message || result.error.code || "unknown_error";
      }

      return new Response(
        JSON.stringify(response),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    const errMsg = err instanceof Error ? err.message : String(err);
    console.error("Edge function error:", errMsg, err);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: errMsg }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
