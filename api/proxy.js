// api/proxy.js
export const config = {
  runtime: 'edge', // Edge Runtime 速度快
};

export default async function handler(request) {
  // 从请求 URL 中解析出查询参数 ?url=...
  const urlParams = new URL(request.url).searchParams;
  const targetUrl = urlParams.get('url');

  if (!targetUrl) {
    return new Response('Missing "url" parameter', { status: 400 });
  }

  try {
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    });

    const newHeaders = new Headers(response.headers);
    newHeaders.set('Access-Control-Allow-Origin', '*'); // 允许所有人访问
    newHeaders.set('Access-Control-Allow-Methods', 'GET, OPTIONS');

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: newHeaders,
    });

  } catch (e) {
    return new Response(`Proxy Error: ${e.message}`, { status: 500 });
  }
}