import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  const url = new URL(req.url);
  const name = url.searchParams.get("name") ?? "world";

  return new Response(
    JSON.stringify({
      ok: true,
      message: `hello ${name}`,
      now: new Date().toISOString(),
    }),
    {
      headers: { "Content-Type": "application/json" },
      status: 200,
    }
  );
});