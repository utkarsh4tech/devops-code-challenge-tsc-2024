function decodeAccessToken(token) {
  const [header, payload, signature] = token.split('.');
  const decodedHeader = base64UrlDecode(header);
  const decodedPayload = base64UrlDecode(payload);

  try {
      return {
          header: JSON.parse(decodedHeader),
          payload: JSON.parse(decodedPayload),
          signature
      };
  } catch (error) {
      return null;
  }
}

function base64UrlDecode(base64Url) {
  const padding = '='.repeat((4 - (base64Url.length % 4)) % 4);
  const base64 = (base64Url + padding).replace(/-/g, '+').replace(/_/g, '/');
  return atob(base64);
}

export { decodeAccessToken }