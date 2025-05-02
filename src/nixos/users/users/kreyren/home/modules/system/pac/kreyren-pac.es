/**
 * @file kreyren-pac.es
 * @description Kreyren's Personal Proxy Automatic Configuration File
 *
 * Documentation:
 * - MDN Docs: [Proxy servers and tunneling](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_PAC_file)
 * - Testing: [Proxy For URL](https://thorsen.pm/proxyforurl)
 *
 * @version 08092024
 * @date 2024-07-27
 * @author Jacob Hrbek <kreyren@fsfe.org>
 * @license EUPL
 */

/**
 * Determines the appropriate proxy for a given URL
 *
 * @param {string} url - The URL to find a proxy for
 * @param {string} host - The host name derived from the URL
 * @returns {string} The proxy to be used
 */
function FindProxyForURL(url, host) {
	// Use ProtonVPN for YouTube as they block Tor
	if (false
		|| (dnsDomainIs(host, "youtube.com") || shExpMatch(host, "(*.youtube.com|youtube.com)"))
		|| (dnsDomainIs(host, "ytimg.com") || shExpMatch(host, "(*.ytimg.com|ytimg.com)"))
		|| (dnsDomainIs(host, "googlevideo.com") || shExpMatch(host, "(*.googlevideo.com|googlevideo.com)"))
		|| (dnsDomainIs(host, "google.com") || shExpMatch(host, "(*.google.com|google.com)"))
	) return "SOCKS5 127.0.0.1:25344"; // Personal ProtonVPN;

	// Dipshits that use cloudflare gates
	if (false
		|| (dnsDomainIs(host, "stackoverflow.com") || shExpMatch(host, "(*.stackoverflow.com|stackoverflow.com)"))
		|| (dnsDomainIs(host, "sstatic.net") || shExpMatch(host, "(*.sstatic.net|sstatic.net)")) // Stackoverflow uses that for assets
		|| (dnsDomainIs(host, "extranix.com") || shExpMatch(host, "(*.extranix.com|extranix.com)"))
		|| (dnsDomainIs(host, "pimsnel.com") || shExpMatch(host, "(*.pimsnel.com|pimsnel.com)")) // Used by extranix for assets
		|| (dnsDomainIs(host, "unpkg.com") || shExpMatch(host, "(*.unpkg.com|unpkg.com)")) // Used by extranix for package database
		|| (dnsDomainIs(host, "gitlab.com") || shExpMatch(host, "(*.gitlab.com|gitlab.com)")) // Used by extranix for package database
		|| (dnsDomainIs(host, "cloudflare.com") || shExpMatch(host, "(*.cloudflare.com|cloudflare.com)"))
		|| (dnsDomainIs(host, "openai.com") || shExpMatch(host, "(*.openai.com|openai.com)"))
		|| (dnsDomainIs(host, "duolicious.app") || shExpMatch(host, "(*.duolicious.app|duolicious.app)"))
		|| (dnsDomainIs(host, "alovoa.com") || shExpMatch(host, "(*.alovoa.com|alovoa.com)"))
	) return "SOCKS5 127.0.0.1:25344"; // Personal ProtonVPN;

	// Block Tor
	if (false
		|| (dnsDomainIs(host, "nxp.com") || shExpMatch(host, "(*.nxp.com|nxp.com)"))
		|| (dnsDomainIs(host, "zi-scripts.com") || shExpMatch(host, "(*.zi-scripts.com|zi-scripts.com)"))
		|| (dnsDomainIs(host, "meta.com") || shExpMatch(host, "(*.meta.com|meta.com)"))
		|| (dnsDomainIs(host, "facebook.com") || shExpMatch(host, "(*.facebook.com|facebook.com)"))
		|| (dnsDomainIs(host, "oculus.com") || shExpMatch(host, "(*.oculus.com|oculus.com)"))
		|| (dnsDomainIs(host, "ocul.us") || shExpMatch(host, "(*.ocul.us|ocul.us)"))
		|| (dnsDomainIs(host, "huggingface.co") || shExpMatch(host, "(*.huggingface.co|huggingface.co)"))
	) return "SOCKS5 127.0.0.1:25344"; // Personal ProtonVPN;

	// Allow direct connections for LAN traffic
	if (isPlainHostName(host) ||
			shExpMatch(host, "*.local") ||
			isInNet(dnsResolve(host), "10.0.0.0", "255.0.0.0") ||
			isInNet(dnsResolve(host), "172.16.0.0",  "255.240.0.0") ||
			isInNet(dnsResolve(host), "192.168.0.0",  "255.255.0.0") ||
			isInNet(dnsResolve(host), "127.0.0.0", "255.255.255.0"))
			return "DIRECT";

	// Proxy traffic if none of the rules above match
	return "SOCKS5 127.0.0.1:9050"; // Local Tor
}
