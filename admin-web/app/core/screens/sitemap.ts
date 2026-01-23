
/**
 * Sitemap Generator Module
 */
export async function loader() {
  const DOMAIN = process.env.SITE_URL || "https://example.com";
  const customUrls = ["/"];

  const sitemapUrls = customUrls.map((url) => {
    return `<url>
      <loc>${DOMAIN}${url}</loc>
      <lastmod>${new Date().toISOString()}</lastmod>
    </url>`;
  });

  return new Response(
    `<?xml version="1.0" encoding="UTF-8"?>
    <urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    >
      ${sitemapUrls.join("\n")}
    </urlset>
    `,
    {
      headers: { "Content-Type": "application/xml" },
    },
  );
}
