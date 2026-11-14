import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const jsonHeaders = { "Content-Type": "application/json" };

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...jsonHeaders, "Allow": "GET" },
    });
  }

  const url = new URL(req.url);
  const keyword = url.searchParams.get("keyword")?.trim();
  const isEnglish = url.searchParams.get("isEnglish") ?? "false";

  if (!keyword || keyword.length > 200) {
    return new Response(JSON.stringify({ error: "Invalid keyword" }), {
      status: 400,
      headers: jsonHeaders,
    });
  }

  if (isEnglish !== "true" && isEnglish !== "false") {
    return new Response(JSON.stringify({ error: "Invalid language option" }), {
      status: 400,
      headers: jsonHeaders,
    });
  }

  const apiKey = Deno.env.get("IGBO_API_KEY");
  if (!apiKey) {
    console.error("search-proxy is missing its IGBO_API_KEY configuration");
    return new Response(JSON.stringify({ error: "Search is temporarily unavailable" }), {
      status: 500,
      headers: jsonHeaders,
    });
  }

  const apiUrl = `https://igboapi.com/api/v2/words?keyword=${encodeURIComponent(keyword)}&isEnglish=${isEnglish}&examples=true&dialects=true`;

  try {
    const response = await fetch(apiUrl, {
      headers: {
        "X-API-Key": apiKey,
        "Accept": "application/json",
      },
    });

    const body = await response.text();
    return new Response(body, {
      status: response.status,
      headers: jsonHeaders,
    });
  } catch (error) {
    console.error(
      "search-proxy upstream request failed",
      error instanceof Error ? error.name : "UnknownError",
    );
    return new Response(JSON.stringify({ error: "Search is temporarily unavailable" }), {
      status: 500,
      headers: jsonHeaders,
    });
  }
});